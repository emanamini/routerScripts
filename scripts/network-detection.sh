#!/usr/bin/env bash
# Module 04: Network Interface Detection & Udev Renaming Rules
set -euo pipefail

echo "=========================================="
echo "Starting Network Interface Detection..."
echo "=========================================="

# ------------------------------------------------------------------------------
# Environment Safety Check
# ------------------------------------------------------------------------------
if [[ -e /run/archiso ]]; then
    echo "Warning: Running inside Arch ISO live environment."
    echo "Ensure you are running this inside your target system chroot, not the live host!"
    echo "------------------------------------------"
fi

UDEV_DIR="/etc/udev/rules.d"
UDEV_RULE_FILE="${UDEV_DIR}/10-network-names.rules"
NETWORKD_DIR="/etc/systemd/network"

# ------------------------------------------------------------------------------
# Helper Functions
# ------------------------------------------------------------------------------

is_physical_interface() {
    [[ -e "/sys/class/net/$1/device" ]]
}

get_mac() {
    <"/sys/class/net/$1/address"
}

# ==============================================================================
# Phase 1: Pre-existing Configuration Check
# ==============================================================================
if grep -rq 'NAME="wan"' "$UDEV_DIR" 2>/dev/null &&
   grep -rq 'NAME="lan"' "$UDEV_DIR" 2>/dev/null; then

    echo "Info: Network interfaces are already assigned as WAN and LAN in udev rules."

    read -r -p \
    "Press [Enter] to keep existing rules and continue, or [Y/y] to edit and replace them: " \
    EDIT_CHOICE </dev/tty

    if [[ ! "$EDIT_CHOICE" =~ ^[Yy]$ ]]; then
        echo "Skipping network detection. Proceeding to next step..."
        exit 0
    fi

    echo "Reconfiguring network interfaces..."
fi

# ==============================================================================
# Phase 2: Physical Interface Discovery
# ==============================================================================

AVAILABLE_INTERFACES=()

for iface_path in /sys/class/net/*; do
    iface=$(basename "$iface_path")

    [[ "$iface" == "lo" ]] && continue

    # Ignore virtual interfaces:
    # docker, bridges, tunnels, VPN interfaces, etc.
    if is_physical_interface "$iface"; then
        AVAILABLE_INTERFACES+=("$iface")
    fi
done

NUM_IFACES=${#AVAILABLE_INTERFACES[@]}

if [[ "$NUM_IFACES" -eq 0 ]]; then
    echo "Error: No physical network interfaces found!" >&2
    exit 1
fi

echo "Detected Physical Network Interfaces:"
for iface in "${AVAILABLE_INTERFACES[@]}"; do
    mac=$(get_mac "$iface")
    echo " - ${iface} (${mac})"
done

echo "------------------------------------------"


# ==============================================================================
# Single Interface Mode
# ==============================================================================

if [[ "$NUM_IFACES" -eq 1 ]]; then

    ONLY_IFACE="${AVAILABLE_INTERFACES[0]}"

    echo "WARNING: Only one physical interface detected (${ONLY_IFACE})."
    echo "A standard router requires at least two interfaces."
    echo "Press Ctrl+C now if this is unexpected."

    read -r -p \
    "Otherwise press [Enter] to assign this interface as WAN: " \
    </dev/tty

    WAN_INTERFACE="$ONLY_IFACE"
    WAN_MAC=$(get_mac "$WAN_INTERFACE")

    mkdir -p "$UDEV_DIR"

    cat > "$UDEV_RULE_FILE" <<EOF
SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="${WAN_MAC}", NAME="wan", OPTIONS+="link_priority=10"
EOF


# ==============================================================================
# Two Interface Mode
# ==============================================================================

else

    DEFAULT_WAN=""

    # Prefer current default route interface
    ROUTE_WAN=$(ip route 2>/dev/null | awk '/default/ {print $5; exit}')

    if [[ -n "$ROUTE_WAN" ]]; then
        for iface in "${AVAILABLE_INTERFACES[@]}"; do
            if [[ "$iface" == "$ROUTE_WAN" ]]; then
                DEFAULT_WAN="$ROUTE_WAN"
                break
            fi
        done
    fi

    # Fallback
    if [[ -z "$DEFAULT_WAN" ]]; then
        DEFAULT_WAN="${AVAILABLE_INTERFACES[0]}"
    fi


    DEFAULT_LAN=""

    for iface in "${AVAILABLE_INTERFACES[@]}"; do
        if [[ "$iface" != "$DEFAULT_WAN" ]]; then
            DEFAULT_LAN="$iface"
            break
        fi
    done


    read -r -p \
    "Enter WAN interface name [Default: ${DEFAULT_WAN}]: " \
    WAN_INTERFACE </dev/tty

    WAN_INTERFACE=${WAN_INTERFACE:-$DEFAULT_WAN}


    if ! is_physical_interface "$WAN_INTERFACE"; then
        echo "Error: WAN interface '${WAN_INTERFACE}' is not a physical NIC!" >&2
        exit 1
    fi


    DEFAULT_LAN=""

    for iface in "${AVAILABLE_INTERFACES[@]}"; do
        if [[ "$iface" != "$WAN_INTERFACE" ]]; then
            DEFAULT_LAN="$iface"
            break
        fi
    done


    read -r -p \
    "Enter LAN interface name [Default: ${DEFAULT_LAN}]: " \
    LAN_INTERFACE </dev/tty

    LAN_INTERFACE=${LAN_INTERFACE:-$DEFAULT_LAN}


    if ! is_physical_interface "$LAN_INTERFACE"; then
        echo "Error: LAN interface '${LAN_INTERFACE}' is not a physical NIC!" >&2
        exit 1
    fi


    if [[ "$WAN_INTERFACE" == "$LAN_INTERFACE" ]]; then
        echo "Error: WAN and LAN cannot use the same interface!" >&2
        exit 1
    fi


    WAN_MAC=$(get_mac "$WAN_INTERFACE")
    LAN_MAC=$(get_mac "$LAN_INTERFACE")


    echo "------------------------------------------"
    echo "WAN Interface: ${WAN_INTERFACE} (${WAN_MAC})"
    echo "LAN Interface: ${LAN_INTERFACE} (${LAN_MAC})"


    mkdir -p "$UDEV_DIR"


    cat > "$UDEV_RULE_FILE" <<EOF
SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="${WAN_MAC}", NAME="wan", OPTIONS+="link_priority=10"
SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="${LAN_MAC}", NAME="lan", OPTIONS+="link_priority=10"
EOF

fi


# ==============================================================================
# Phase 3: systemd-networkd Configuration
# ==============================================================================

echo "Generating systemd-networkd configuration files..."

mkdir -p "$NETWORKD_DIR"


cat > "${NETWORKD_DIR}/wan.network" <<EOF
[Match]
Name=wan

[Network]
DHCP=yes
EOF


cat > "${NETWORKD_DIR}/lan.network" <<EOF
[Match]
Name=lan

[Network]
Address=172.22.0.1/24
Address=10.10.10.10/32
EOF


# ==============================================================================
# Phase 4: DNS Configuration
# ==============================================================================

echo "Configuring static DNS..."

SKIP_DNS=0


if mountpoint -q /etc/resolv.conf; then

    echo "Detected mounted /etc/resolv.conf"

    if umount /etc/resolv.conf 2>/dev/null; then
        echo "Unmounted /etc/resolv.conf"
    else
        echo "Warning: Cannot unmount /etc/resolv.conf"
        SKIP_DNS=1
    fi

fi


if [[ "$SKIP_DNS" -eq 0 ]]; then

    rm -f /etc/resolv.conf

    cat > /etc/resolv.conf <<EOF
# Generated by Router Installer
nameserver 8.8.8.8
nameserver 1.1.1.1
nameserver 9.9.9.9
EOF

    chmod 644 /etc/resolv.conf

fi


# ==============================================================================
# Permissions and Activation
# ==============================================================================

chmod 644 "$UDEV_RULE_FILE" 2>/dev/null || true
chmod 644 "${NETWORKD_DIR}/wan.network"
chmod 644 "${NETWORKD_DIR}/lan.network"


echo "Reloading udev rules..."
udevadm control --reload-rules 2>/dev/null || true


echo "Enabling systemd-networkd..."

systemctl enable systemd-networkd 2>/dev/null || \
echo "Warning: Could not enable systemd-networkd (expected inside chroot)"


echo
echo "=========================================="
echo "Network detection: OK"
echo "=========================================="

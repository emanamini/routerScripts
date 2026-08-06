#!/usr/bin/env bash
# Module 04: Network Interface Detection & Udev Renaming Rules
set -euo pipefail

echo "=========================================="
echo "Starting Network Interface Detection..."
echo "=========================================="

UDEV_DIR="/etc/udev/rules.d"
UDEV_RULE_FILE="${UDEV_DIR}/10-network-names.rules"
NETWORKD_DIR="/etc/systemd/network"

# ==============================================================================
# Phase 1: Pre-existing Configuration Check (State 0)
# ==============================================================================
if grep -rq 'NAME="wan"' "$UDEV_DIR" 2>/dev/null && grep -rq 'NAME="lan"' "$UDEV_DIR" 2>/dev/null; then
    echo "Info: Network interfaces are already assigned as WAN and LAN in udev rules."
    read -r -p "Press [Enter] to keep existing rules and continue, or press [Y/y] to edit and replace them: " EDIT_CHOICE </dev/tty
    if [[ ! "$EDIT_CHOICE" =~ ^[Yy]$ ]]; then
        echo "Skipping network detection. Proceeding to next step..."
        return 0 2>/dev/null || exit 0
    fi
    echo "Reconfiguring network interfaces..."
fi

# ==============================================================================
# Phase 2: Interface Discovery (State 1)
# ==============================================================================
# Discover active interfaces excluding loopback (lo)
AVAILABLE_INTERFACES=($(ls /sys/class/net | grep -v '^lo$'))
NUM_IFACES=${#AVAILABLE_INTERFACES[@]}

if [[ $NUM_IFACES -eq 0 ]]; then
    echo "Error: No physical network interfaces found!" >&2
    exit 1
fi

echo "Detected Network Interfaces:"
for iface in "${AVAILABLE_INTERFACES[@]}"; do
    mac=$(cat "/sys/class/net/${iface}/address")
    echo " - ${iface} (${mac})"
done
echo "------------------------------------------"

# --- Edge Case: Single Link ---
if [[ $NUM_IFACES -eq 1 ]]; then
    ONLY_IFACE="${AVAILABLE_INTERFACES[0]}"
    echo "WARNING: Only one network interface detected (${ONLY_IFACE})."
    echo "A standard router setup requires at least two physical interfaces."
    echo "If this is a hardware error, press Ctrl+C NOW to abort and fix the hardware."
    read -r -p "Otherwise, press [Enter] to assign this single interface as WAN and continue..." </dev/tty

    WAN_INTERFACE="$ONLY_IFACE"
    WAN_MAC=$(cat "/sys/class/net/${WAN_INTERFACE}/address")

    echo "Generating udev network rule for WAN..."
    mkdir -p "$UDEV_DIR"
    cat <<EOF > "$UDEV_RULE_FILE"
SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="${WAN_MAC}", NAME="wan"
EOF
    # We leave LAN variables empty for this edge case

# ==============================================================================
# Phase 3: Smart Defaults & Two-Link Assignment (State 2)
# ==============================================================================
else
    DEFAULT_WAN=""
    DEFAULT_LAN=""

    # 1. Check for IPv4 and prioritize "192." for WAN default
    for iface in "${AVAILABLE_INTERFACES[@]}"; do
        # Check if interface has an IPv4 address
        if ip -4 addr show dev "$iface" 2>/dev/null | grep -q 'inet '; then
            # If it starts with 192., it takes priority
            if ip -4 addr show dev "$iface" 2>/dev/null | grep -q 'inet 192\.'; then
                DEFAULT_WAN="$iface"
                break
            # Otherwise, set it as default WAN but keep checking for a 192. address
            elif [[ -z "$DEFAULT_WAN" ]]; then
                DEFAULT_WAN="$iface"
            fi
        fi
    done

    # 2. If no IPv4 was found at all, just default to the first interface
    if [[ -z "$DEFAULT_WAN" ]]; then
        DEFAULT_WAN="${AVAILABLE_INTERFACES[0]}"
    fi

    # 3. Default LAN is the first remaining interface
    for iface in "${AVAILABLE_INTERFACES[@]}"; do
        if [[ "$iface" != "$DEFAULT_WAN" ]]; then
            DEFAULT_LAN="$iface"
            break
        fi
    done

    # Prompt for WAN
    read -r -p "Enter WAN interface name [Default: ${DEFAULT_WAN}]: " WAN_INTERFACE </dev/tty
    WAN_INTERFACE=${WAN_INTERFACE:-$DEFAULT_WAN}

    if [[ ! -d "/sys/class/net/${WAN_INTERFACE}" ]]; then
        echo "Error: Interface '${WAN_INTERFACE}' does not exist!" >&2
        exit 1
    fi

    # Re-evaluate default LAN in case the user manually picked a different WAN
    for iface in "${AVAILABLE_INTERFACES[@]}"; do
        if [[ "$iface" != "$WAN_INTERFACE" ]]; then
            DEFAULT_LAN="$iface"
            break
        fi
    done

    # Prompt for LAN
    read -r -p "Enter LAN interface name [Default: ${DEFAULT_LAN}]: " LAN_INTERFACE </dev/tty
    LAN_INTERFACE=${LAN_INTERFACE:-$DEFAULT_LAN}

    if [[ ! -d "/sys/class/net/${LAN_INTERFACE}" ]]; then
        echo "Error: Interface '${LAN_INTERFACE}' does not exist!" >&2
        exit 1
    fi

    # Check for duplicate assignment
    if [[ "${WAN_INTERFACE}" == "${LAN_INTERFACE}" ]]; then
        echo "Error: WAN and LAN interfaces cannot be the same (${WAN_INTERFACE})!" >&2
        exit 1
    fi

    # Extract MAC addresses
    WAN_MAC=$(cat "/sys/class/net/${WAN_INTERFACE}/address")
    LAN_MAC=$(cat "/sys/class/net/${LAN_INTERFACE}/address")

    echo "------------------------------------------"
    echo "WAN Interface: ${WAN_INTERFACE} [${WAN_MAC}]"
    echo "LAN Interface: ${LAN_INTERFACE} [${LAN_MAC}]"

    # Generate persistent udev rules for predictable interface naming
    echo "Generating udev network rules at ${UDEV_RULE_FILE}..."
    mkdir -p "$UDEV_DIR"

    cat <<EOF > "${UDEV_RULE_FILE}"
SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="${WAN_MAC}", NAME="wan"
SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="${LAN_MAC}", NAME="lan"
EOF
fi

# ==============================================================================
# Phase 4: Generate systemd-networkd Configurations & DNS
# ==============================================================================
echo "Generating systemd-networkd configuration files..."
mkdir -p "$NETWORKD_DIR"

cat <<EOF > "${NETWORKD_DIR}/wan.network"
[Match]
Name=wan

[Network]
DHCP=yes
EOF

cat <<EOF > "${NETWORKD_DIR}/lan.network"
[Match]
Name=lan

[Network]
Address=172.22.0.1/24
Address=10.10.10.10/32
EOF

echo "Configuring static DNS in /etc/resolv.conf..."
# Remove potential symlinks (like systemd-resolved stubs) to ensure we write a real file
rm -f /etc/resolv.conf
cat <<EOF > /etc/resolv.conf
# Generated by Router Installer
nameserver 8.8.8.8
nameserver 1.1.1.1
nameserver 9.9.9.9
EOF

# Apply permissions
chmod 644 "${UDEV_RULE_FILE}" 2>/dev/null || true
chmod 644 "${NETWORKD_DIR}/wan.network"
chmod 644 "${NETWORKD_DIR}/lan.network"
chmod 644 /etc/resolv.conf

echo "  - Generated udev persistent naming rules."
echo "  - Generated systemd-networkd files (wan.network, lan.network)."
echo "  - Set static nameservers in /etc/resolv.conf."
echo "  - Enabling the service."
# Safely enable the service (creates symlinks, does not attempt to start in chroot)
systemctl enable systemd-networkd 2>/dev/null || echo "Warning: Could not enable systemd-networkd (expected if not using systemd as init)"
echo "Network detection: OK"

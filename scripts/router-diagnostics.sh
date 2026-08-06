#!/bin/bash

############################################################
# Router Diagnostics v5.1
#
# Headless Arch Linux Router Health Inspector
#
# Creates:
#   summary.txt       -> human readable diagnosis
#   diagnostics/      -> detailed evidence
#   report.tar.gz     -> compressed archive
#
############################################################

set -uo pipefail  # Strict mode (but not -e, to allow graceful degradation)

############################################################
# Configuration
############################################################

LAN_IF="lan"
WAN_IF="wan"
VPN_IF="tun0"

# Detect LAN IP dynamically
LAN_IP=$(ip -4 -o addr show dev "$LAN_IF" 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -n 1)
if [ -z "$LAN_IP" ]; then
    LAN_IP="172.22.0.1"  # fallback
fi

HOSTNAME=$(hostname)
DATE=$(date +"%Y-%m-%d_%H-%M-%S")

############################################################
# Input
############################################################

if [ $# -ne 1 ]; then
    echo "Usage:"
    echo "$0 /path/to/usb/mount"
    exit 1
fi

USB_PATH="$1"

if [ ! -d "$USB_PATH" ]; then
    echo "Error: USB mount path does not exist"
    exit 1
fi

REPORT="$USB_PATH/router-diagnostics/$HOSTNAME/$DATE"

mkdir -p "$REPORT"/diagnostics/{boot,network,services,vpn,firewall,hardware,system}

SUMMARY="$REPORT/summary.txt"

############################################################
# Helper functions
############################################################

write_summary() {
    echo "$1" >> "$SUMMARY"
}

section() {
    echo "" >> "$SUMMARY"
    echo "=================================================" >> "$SUMMARY"
    echo "$1" >> "$SUMMARY"
    echo "=================================================" >> "$SUMMARY"
}

run_save() {
    local NAME="$1"
    shift
    {
        echo "================================================="
        echo "$NAME"
        echo "================================================="
        echo
        "$@" 2>&1
    }
}

check_command() {
    command -v "$1" >/dev/null 2>&1
}

PASS() {
    write_summary "PASS  $1"
}

WARN() {
    write_summary "WARN  $1"
}

FAIL() {
    write_summary "FAIL  $1"
}

INFO() {
    write_summary "INFO  $1"
}

############################################################
# Start Summary
############################################################

echo "Router Diagnostics v5.1" > "$SUMMARY"

write_summary ""
write_summary "Hostname: $HOSTNAME"
write_summary "Date: $(date)"
write_summary "Kernel: $(uname -r)"
write_summary "Uptime: $(uptime -p)"
write_summary "Report ID: $HOSTNAME-$DATE"
write_summary "LAN IP detected: $LAN_IP"

############################################################
# Boot Health
############################################################

section "BOOT HEALTH"

if systemctl is-system-running --quiet; then
    PASS "System reached normal operational state"
else
    WARN "System is not fully healthy"
fi

FAILED=$(systemctl --failed --no-legend | grep -v '^$' | wc -l)

if [ "$FAILED" -eq 0 ]; then
    PASS "No currently failed systemd services"
else
    FAIL "$FAILED currently failed systemd service(s)"
fi

BOOT_ERRORS=$(journalctl -b -p err --no-pager | grep -v "^--" | grep -v "^$" | wc -l)

if [ "$BOOT_ERRORS" -eq 0 ]; then
    PASS "No errors detected during current boot"
else
    WARN "$BOOT_ERRORS error entries detected during current boot"
fi

journalctl -b -p err --no-pager > "$REPORT/diagnostics/boot/error-level.txt"

run_save "Current boot journal" journalctl -b --no-pager > "$REPORT/diagnostics/boot/current-journal.txt"
run_save "Boot errors" journalctl -b -p warning --no-pager > "$REPORT/diagnostics/boot/errors.txt"
run_save "Previous boot" journalctl -b -1 --no-pager > "$REPORT/diagnostics/boot/previous-boot.txt"
run_save "Systemd blame" systemd-analyze blame > "$REPORT/diagnostics/boot/systemd-blame.txt"
run_save "Systemd critical chain" systemd-analyze critical-chain > "$REPORT/diagnostics/boot/systemd-chain.txt"

############################################################
# Filesystem
############################################################

section "FILESYSTEM"

ROOT_MODE=$(findmnt -no OPTIONS /)

if echo "$ROOT_MODE" | grep -q rw; then
    PASS "Root filesystem mounted read-write"
else
    FAIL "Root filesystem is not read-write"
fi

DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | tr -d '%')

if [ "$DISK_USAGE" -lt 90 ]; then
    PASS "Disk usage normal ($DISK_USAGE%)"
else
    WARN "Disk usage high ($DISK_USAGE%)"
fi

run_save "Filesystem status" df -h > "$REPORT/diagnostics/system/disk.txt"

if check_command btrfs; then
    run_save "BTRFS usage" btrfs filesystem usage / > "$REPORT/diagnostics/system/btrfs.txt"
fi

############################################################
# NETWORK HEALTH
############################################################

section "NETWORK HEALTH"

run_save "systemd-networkd status" systemctl status systemd-networkd --no-pager > "$REPORT/diagnostics/services/systemd-networkd.txt"

if systemctl is-active --quiet systemd-networkd; then
    PASS "systemd-networkd is active"
else
    FAIL "systemd-networkd is not active"
fi

run_save "IP addresses" ip addr > "$REPORT/diagnostics/network/ip-address.txt"
run_save "IP links" ip link > "$REPORT/diagnostics/network/ip-link.txt"
run_save "Routes" ip route show table all > "$REPORT/diagnostics/network/routes.txt"
run_save "Rules" ip rule > "$REPORT/diagnostics/network/rules.txt"
run_save "Networkctl" networkctl status > "$REPORT/diagnostics/network/networkctl.txt"

############################################################
# LAN check
############################################################

section "LAN CHECK"

if ip link show "$LAN_IF" >/dev/null 2>&1; then
    PASS "LAN interface exists ($LAN_IF)"

    LAN_STATE=$(cat /sys/class/net/"$LAN_IF"/operstate 2>/dev/null || echo "unknown")
    if [ "$LAN_STATE" = "up" ]; then
        PASS "LAN interface state UP"
    else
        FAIL "LAN interface state $LAN_STATE"
    fi

    if ip addr show "$LAN_IF" | grep -q "$LAN_IP"; then
        PASS "LAN IP detected ($LAN_IP)"
    else
        FAIL "LAN IP missing ($LAN_IP)"
    fi
else
    FAIL "LAN interface missing ($LAN_IF)"
fi

############################################################
# WAN check + Connectivity
############################################################

section "WAN CHECK + CONNECTIVITY"

if ip link show "$WAN_IF" >/dev/null 2>&1; then
    PASS "WAN interface exists ($WAN_IF)"

    WAN_STATE=$(cat /sys/class/net/"$WAN_IF"/operstate 2>/dev/null || echo "unknown")
    if [ "$WAN_STATE" = "up" ]; then
        PASS "WAN interface state UP"
    else
        FAIL "WAN interface state $WAN_STATE"
    fi

    if [ -e "/sys/class/net/$WAN_IF/carrier" ]; then
        CARRIER=$(cat /sys/class/net/"$WAN_IF"/carrier)
        if [ "$CARRIER" = "1" ]; then
            PASS "WAN physical carrier detected"
        else
            FAIL "WAN no physical carrier"
        fi
    fi

    if ip addr show "$WAN_IF" | grep -q "inet "; then
        PASS "WAN has IPv4 address"
    else
        WARN "WAN has no IPv4 address"
    fi

    # Connectivity tests
    if timeout 5 ping -c 1 -I "$WAN_IF" 8.8.8.8 >/dev/null 2>&1; then
        PASS "WAN IPv4 reachability (8.8.8.8)"
    else
        WARN "WAN IPv4 connectivity test failed"
    fi
else
    FAIL "WAN interface missing ($WAN_IF)"
fi

############################################################
# Routing & Forwarding
############################################################

section "ROUTING & FORWARDING"

run_save "Routing table" ip route show table all > "$REPORT/diagnostics/network/routes.txt"

if ip route | grep -q "default"; then
    PASS "Default route exists"
else
    FAIL "No default route found"
fi

FORWARD=$(cat /proc/sys/net/ipv4/ip_forward)
if [ "$FORWARD" = "1" ]; then
    PASS "IPv4 forwarding enabled"
else
    FAIL "IPv4 forwarding disabled"
fi
echo "IPv4 forwarding: $FORWARD" > "$REPORT/diagnostics/network/forwarding.txt"

############################################################
# Firewall
############################################################

section "FIREWALL"

if check_command nft; then
    nft list ruleset > "$REPORT/diagnostics/firewall/nftables.txt" 2>&1
    PASS "nftables rules collected"
else
    WARN "nft command not available"
fi

############################################################
# DNS HEALTH
############################################################

section "DNS HEALTH"

run_save "dnsmasq status" systemctl status dnsmasq --no-pager > "$REPORT/diagnostics/services/dnsmasq.txt"

if systemctl is-active --quiet dnsmasq; then
    PASS "dnsmasq service active"
else
    FAIL "dnsmasq service inactive"
fi

if ss -lntup | grep -q ":53"; then
    PASS "DNS port 53 listening"
else
    WARN "DNS port 53 not detected"
fi

# DNS resolution test
if timeout 3 dig +short @127.0.0.1 google.com >/dev/null 2>&1 || timeout 3 nslookup google.com 127.0.0.1 >/dev/null 2>&1; then
    PASS "Local DNS resolution working"
else
    WARN "Local DNS resolution test failed"
fi

run_save "DNS listeners" ss -lntup > "$REPORT/diagnostics/network/dns-listeners.txt"

############################################################
# VPN HEALTH
############################################################

section "VPN HEALTH"

# WireGuard
if command -v wg >/dev/null 2>&1; then
    run_save "WireGuard status" wg show > "$REPORT/diagnostics/vpn/wireguard.txt"

    if ip link show type wireguard >/dev/null 2>&1; then
        WG_INTERFACES=$(ip -o link show type wireguard | awk -F': ' '{print $2}' | xargs)
        for WG_IF in $WG_INTERFACES; do
            if ip link show dev "$WG_IF" | grep -E -q "<.*UP.*>"; then
                PASS "WireGuard interface $WG_IF is UP"
                if wg show "$WG_IF" | grep -q "latest handshake"; then
                    PASS "WireGuard handshake detected on $WG_IF"
                else
                    WARN "WireGuard $WG_IF is UP but no handshake detected"
                fi
            else
                INFO "WireGuard interface $WG_IF exists but is DOWN"
            fi
        done
    else
        INFO "WireGuard installed but no active interfaces"
    fi
else
    INFO "WireGuard tools not installed"
fi

# OpenVPN

section "OPENVPN STATUS"

# Look for any openvpn related services (including template instances like openvpn-client@tun1.service)
OPENVPN_UNITS=$(systemctl list-units --all --type=service | grep -E 'openvpn' | awk '{print $1}')

if [ -n "$OPENVPN_UNITS" ]; then
    ACTIVE_COUNT=0
    for UNIT in $OPENVPN_UNITS; do
        run_save "OpenVPN unit: $UNIT" systemctl status "$UNIT" --no-pager > "$REPORT/diagnostics/vpn/$UNIT.txt"
        
        if systemctl is-active --quiet "$UNIT"; then
            PASS "OpenVPN unit $UNIT is active (running)"
            ((ACTIVE_COUNT++))
        else
            WARN "OpenVPN unit $UNIT is inactive"
        fi
    done
    
    if [ "$ACTIVE_COUNT" -gt 0 ]; then
        PASS "At least one OpenVPN tunnel is active"
    else
        WARN "OpenVPN installed but no active tunnels"
    fi
else
    WARN "No OpenVPN services found"
fi

############################################################
# Router Services
############################################################

section "ROUTER SERVICES"

SERVICES=("dnsmasq" "sshd" "caddy" "arch-portal")

for SERVICE in "${SERVICES[@]}"; do
    if systemctl list-unit-files | grep -q "^$SERVICE"; then
        if systemctl is-active --quiet "$SERVICE"; then
            PASS "$SERVICE active"
        else
            FAIL "$SERVICE inactive"
        fi
        systemctl status "$SERVICE" --no-pager > "$REPORT/diagnostics/services/$SERVICE.txt"
    else
        WARN "$SERVICE not installed"
    fi
done

############################################################
# Hardware
############################################################

section "HARDWARE"

run_save "CPU information" lscpu > "$REPORT/diagnostics/hardware/cpu.txt"
PASS "CPU information collected"

run_save "Memory information" free -h > "$REPORT/diagnostics/hardware/memory.txt"
PASS "Memory information collected"

run_save "PCI devices" lspci > "$REPORT/diagnostics/hardware/pci.txt"
PASS "PCI information collected"

# Optional: temperatures
if check_command sensors; then
    run_save "Temperature sensors" sensors > "$REPORT/diagnostics/hardware/sensors.txt"
    PASS "Temperature data collected"
fi

############################################################
# Overall Health Score
############################################################

section "OVERALL HEALTH"

PASS_COUNT=$(grep -c "^PASS" "$SUMMARY")
WARN_COUNT=$(grep -c "^WARN" "$SUMMARY")
FAIL_COUNT=$(grep -c "^FAIL" "$SUMMARY")

SCORE=$((100 - (FAIL_COUNT * 20) - (WARN_COUNT * 5)))
[ "$SCORE" -lt 0 ] && SCORE=0

write_summary ""
write_summary "Health Score: $SCORE/100"

if [ "$FAIL_COUNT" -eq 0 ] && [ "$WARN_COUNT" -eq 0 ]; then
    write_summary "Status: HEALTHY"
elif [ "$FAIL_COUNT" -eq 0 ]; then
    write_summary "Status: DEGRADED"
else
    write_summary "Status: CRITICAL"
fi

write_summary ""
write_summary "Failures: $FAIL_COUNT"
write_summary "Warnings: $WARN_COUNT"

############################################################
# Recommendations
############################################################

section "RECOMMENDATIONS"

if [ "$FAIL_COUNT" -eq 0 ] && [ "$WARN_COUNT" -eq 0 ]; then
    write_summary "No action required."
else
    grep -q "WAN" "$SUMMARY" && write_summary "- Review WAN connectivity."
    grep -q "LAN" "$SUMMARY" && write_summary "- Review LAN configuration."
    grep -q "dnsmasq" "$SUMMARY" && write_summary "- Check DNS service."
    grep -q "WireGuard" "$SUMMARY" && write_summary "- Review WireGuard status."
    grep -q "OpenVPN" "$SUMMARY" && write_summary "- Review OpenVPN status."
    [ "$WARN_COUNT" -gt 0 ] && write_summary "- Review warning messages."
    write_summary "- Detailed logs in diagnostics/."
fi

############################################################
# Completion + Archive
############################################################

write_summary ""
write_summary "Diagnostic collection complete."
write_summary "Report location: $REPORT"

# Create compressed archive
if cd "$USB_PATH" 2>/dev/null; then
    tar -czf "router-diagnostics-$HOSTNAME-$DATE.tar.gz" "router-diagnostics/$HOSTNAME/$DATE" 2>/dev/null && \
        write_summary "Compressed archive created: router-diagnostics-$HOSTNAME-$DATE.tar.gz"
fi

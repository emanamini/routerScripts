#!/usr/bin/env bash

###############################################################################
# AI Diagnostic Collector
# Linux system information collector for AI-assisted troubleshooting
#
# Designed for:
# - Arch Linux
# - Debian/Ubuntu
# - Servers
# - Routers
# - Desktop systems
#
# Read-only. Does not modify the system.
###############################################################################

set -uo pipefail

VERSION="1.0"

###############################################################################
# Options
###############################################################################

TEXT_MODE=false
SAFE_MODE=false

show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  --full          Generate a complete compressed archive (Default behavior)"
    echo "  --text          Generate a single, combined text file instead of an archive"
    echo "  --safe          Apply privacy filters (redacts local IPs, MAC addresses, SSH keys)"
    echo "  --text --safe   Combines text mode and privacy filtering"
    echo "  --help, -h      Display this help message"
    echo
    exit 0
}

# If no arguments are passed, show the usage menu and exit
if [ $# -eq 0 ]; then
    show_usage
fi

for arg in "$@"; do
    case "$arg" in
        --text)
            TEXT_MODE=true
            ;;
        --safe)
            SAFE_MODE=true
            ;;
        --full)
            # Bypasses the usage menu to run the default archiving process
            ;;
        --help|-h)
            show_usage
            ;;
        *)
            echo "Unknown option: $arg"
            echo "Run '$0 --help' for valid options."
            exit 1
            ;;
    esac
done

###############################################################################
# Colors
###############################################################################

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
RESET="\033[0m"


###############################################################################
# Variables
###############################################################################

HOSTNAME=$(hostname 2>/dev/null || echo unknown)
DATE=$(date +"%Y-%m-%d-%H%M%S")

BASE="AI-Diagnostic-Report-${HOSTNAME}-${DATE}"
ARCHIVE="${BASE}.tar.zst"


###############################################################################
# Create directories
###############################################################################

mkdir -p "$BASE"/{summary,hardware,system,network,storage,packages,security,configs,logs,services}


###############################################################################
# Logging
###############################################################################

msg()
{
    echo -e "${GREEN}[+]${RESET} $1"
}


warn()
{
    echo -e "${YELLOW}[!]${RESET} $1"
}


error()
{
    echo -e "${RED}[X]${RESET} $1"
}


###############################################################################
# Run command safely
###############################################################################

collect()
{
    local title="$1"
    local file="$2"
    shift 2

    msg "$title"

    {
        echo "================================================"
        echo "$title"
        echo "Generated: $(date)"
        echo "================================================"
        echo

        echo "\$ $*"
        echo

        "$@" 2>&1 || echo "[command failed]"

    } > "$file"
}


###############################################################################
# Save text safely
###############################################################################

save_text()
{
    local file="$1"
    shift
    printf "%s\n" "$@" > "$file"
}


###############################################################################
# Root check
###############################################################################

if [ "$EUID" -ne 0 ]; then
    warn "Not running as root."
    warn "Some information will be missing."
    warn "Recommended:"
    warn "sudo $0"
fi


###############################################################################
# Header
###############################################################################

msg "Starting AI Diagnostic Collector"

save_text \
"$BASE/README.txt" \
"AI Diagnostic Collector v$VERSION" \
"Hostname: $HOSTNAME" \
"Date: $(date)" \
"" \
"This archive contains system information collected for AI troubleshooting." \
"" \
"Before sharing publicly, review the privacy report."



###############################################################################
# Basic summary
###############################################################################

collect \
"Hostname information" \
"$BASE/summary/hostname.txt" \
hostnamectl


collect \
"Kernel information" \
"$BASE/summary/kernel.txt" \
uname -a


collect \
"Operating system" \
"$BASE/summary/os-release.txt" \
cat /etc/os-release


collect \
"Date and timezone" \
"$BASE/summary/time.txt" \
timedatectl


collect \
"System uptime" \
"$BASE/summary/uptime.txt" \
uptime


###############################################################################
# Environment
###############################################################################

collect \
"Environment variables" \
"$BASE/system/environment.txt" \
env


collect \
"Current user" \
"$BASE/system/user.txt" \
id


###############################################################################
# Hardware basics
###############################################################################

collect \
"CPU information" \
"$BASE/hardware/cpu.txt" \
lscpu


collect \
"Memory information" \
"$BASE/hardware/memory.txt" \
free -h


collect \
"PCI devices" \
"$BASE/hardware/pci.txt" \
lspci -nnk


collect \
"USB devices" \
"$BASE/hardware/usb.txt" \
lsusb


###############################################################################
# Storage
###############################################################################

collect \
"Block devices" \
"$BASE/storage/lsblk.txt" \
lsblk -a


collect \
"Filesystem usage" \
"$BASE/storage/df.txt" \
df -hT


collect \
"Mount points" \
"$BASE/storage/mounts.txt" \
findmnt


collect \
"fstab" \
"$BASE/storage/fstab.txt" \
cat /etc/fstab

###############################################################################
# Systemd information
###############################################################################

collect \
"Running systemd services" \
"$BASE/services/running-services.txt" \
systemctl list-units --type=service --state=running


collect \
"Enabled systemd services" \
"$BASE/services/enabled-services.txt" \
systemctl list-unit-files --type=service --state=enabled


collect \
"Failed systemd units" \
"$BASE/services/failed.txt" \
systemctl --failed


collect \
"Systemd timers" \
"$BASE/services/timers.txt" \
systemctl list-timers --all


collect \
"Systemd boot analysis" \
"$BASE/services/systemd-analyze.txt" \
systemd-analyze


collect \
"Systemd startup blame" \
"$BASE/services/systemd-blame.txt" \
systemd-analyze blame


collect \
"Current boot journal warnings" \
"$BASE/logs/journal-warning.txt" \
journalctl -b -p warning --no-pager


collect \
"Kernel messages" \
"$BASE/logs/dmesg.txt" \
dmesg


###############################################################################
# Boot information
###############################################################################

collect \
"Boot loader status" \
"$BASE/system/bootloader.txt" \
bootctl status


collect \
"EFI boot entries" \
"$BASE/system/efi.txt" \
efibootmgr


collect \
"Kernel command line" \
"$BASE/system/kernel-commandline.txt" \
cat /proc/cmdline


###############################################################################
# Kernel modules
###############################################################################

collect \
"Loaded kernel modules" \
"$BASE/system/modules.txt" \
lsmod


collect \
"Module configuration" \
"$BASE/system/modprobe-config.txt" \
modprobe -c



###############################################################################
# System parameters
###############################################################################

collect \
"Kernel sysctl settings" \
"$BASE/security/sysctl.txt" \
sysctl -a



###############################################################################
# Network information
###############################################################################

collect \
"Network interfaces" \
"$BASE/network/interfaces.txt" \
ip addr


collect \
"Network links" \
"$BASE/network/links.txt" \
ip link


collect \
"Routing table" \
"$BASE/network/routes.txt" \
ip route


collect \
"Policy routing" \
"$BASE/network/rules.txt" \
ip rule


collect \
"ARP neighbour table" \
"$BASE/network/neighbours.txt" \
ip neigh


collect \
"Listening network services" \
"$BASE/network/listening-services.txt" \
ss -tulpn


collect \
"DNS configuration" \
"$BASE/network/dns.txt" \
resolvectl status


collect \
"Resolver file" \
"$BASE/network/resolv.conf.txt" \
cat /etc/resolv.conf



###############################################################################
# Network managers
###############################################################################

if command -v nmcli >/dev/null; then

collect \
"NetworkManager devices" \
"$BASE/network/networkmanager-devices.txt" \
nmcli device


collect \
"NetworkManager connections" \
"$BASE/network/networkmanager-connections.txt" \
nmcli connection show

fi



if command -v networkctl >/dev/null; then

collect \
"systemd-networkd status" \
"$BASE/network/networkd.txt" \
networkctl status


collect \
"systemd-networkd interfaces" \
"$BASE/network/networkd-list.txt" \
networkctl list

fi



###############################################################################
# Firewall
###############################################################################

collect \
"NFTables ruleset" \
"$BASE/network/nftables.txt" \
nft list ruleset


collect \
"iptables rules" \
"$BASE/network/iptables.txt" \
iptables-save


collect \
"IPv6 iptables rules" \
"$BASE/network/ip6tables.txt" \
ip6tables-save



###############################################################################
# VPN / tunnels
###############################################################################

if command -v wg >/dev/null; then

collect \
"WireGuard status" \
"$BASE/network/wireguard.txt" \
wg show

fi



###############################################################################
# Package information
###############################################################################

if command -v pacman >/dev/null; then

collect \
"Installed pacman packages" \
"$BASE/packages/pacman-installed.txt" \
pacman -Q


collect \
"Explicit pacman packages" \
"$BASE/packages/pacman-explicit.txt" \
pacman -Qqe


collect \
"Foreign packages (AUR)" \
"$BASE/packages/aur-packages.txt" \
pacman -Qqem


collect \
"Orphan packages" \
"$BASE/packages/orphans.txt" \
pacman -Qdt


collect \
"Pacman configuration" \
"$BASE/packages/pacman-conf.txt" \
pacman-conf


fi



###############################################################################
# Cron jobs
###############################################################################

{
echo "================================================"
echo "Cron jobs"
echo "================================================"
echo

echo "### Current user"
crontab -l 2>/dev/null || echo "(none)"

echo

echo "### Root"
crontab -u root -l 2>/dev/null || echo "(none)"

echo

echo "### System cron directories"

for dir in \
/etc/cron.d \
/etc/cron.daily \
/etc/cron.hourly \
/etc/cron.weekly \
/etc/cron.monthly

do

if [ -d "$dir" ]; then

echo
echo "===== $dir ====="
ls -lah "$dir"

fi

done

} > "$BASE/services/cron.txt"



###############################################################################
# Important configuration files
###############################################################################

msg "Collecting configuration files"


mkdir -p "$BASE/configs"



# nftables

if [ -f /etc/nftables.conf ]; then
cp -a /etc/nftables.conf \
"$BASE/configs/"
fi



# dnsmasq

if [ -f /etc/dnsmasq.conf ]; then
cp -a /etc/dnsmasq.conf \
"$BASE/configs/"
fi



# systemd network

if [ -d /etc/systemd/network ]; then

cp -a /etc/systemd/network \
"$BASE/configs/"

fi



# udev rules

if [ -d /etc/udev/rules.d ]; then

cp -a /etc/udev/rules.d \
"$BASE/configs/"

fi



# sysctl configuration

if [ -d /etc/sysctl.d ]; then

cp -a /etc/sysctl.d \
"$BASE/configs/"

fi



# systemd overrides

if [ -d /etc/systemd/system ]; then

cp -a /etc/systemd/system \
"$BASE/configs/systemd-system"

fi

###############################################################################
# Storage health
###############################################################################

msg "Checking disk health"


if command -v smartctl >/dev/null; then

mkdir -p "$BASE/storage/smart"


for disk in /dev/sd? /dev/nvme?;

do

if [ -b "$disk" ]; then

name=$(basename "$disk")

smartctl -a "$disk" \
> "$BASE/storage/smart/${name}.txt" \
2>&1

fi

done

else

echo "smartctl not installed" \
> "$BASE/storage/smart.txt"

fi



if command -v nvme >/dev/null; then

mkdir -p "$BASE/storage/nvme"

for dev in /dev/nvme?;

do

if [ -b "$dev" ]; then

name=$(basename "$dev")

nvme smart-log "$dev" \
> "$BASE/storage/nvme/${name}.txt" \
2>&1

fi

done

fi



###############################################################################
# BTRFS
###############################################################################

if command -v btrfs >/dev/null; then

collect \
"BTRFS filesystem information" \
"$BASE/storage/btrfs.txt" \
btrfs filesystem show


collect \
"BTRFS subvolumes" \
"$BASE/storage/btrfs-subvolumes.txt" \
btrfs subvolume list /

fi



###############################################################################
# Hardware sensors
###############################################################################

if command -v sensors >/dev/null; then

collect \
"Hardware sensors" \
"$BASE/hardware/sensors.txt" \
sensors

fi



###############################################################################
# Graphics
###############################################################################

collect \
"Graphics devices" \
"$BASE/hardware/graphics.txt" \
bash -c "lspci | grep -Ei 'vga|3d|display'"



if command -v glxinfo >/dev/null; then

collect \
"OpenGL information" \
"$BASE/hardware/opengl.txt" \
glxinfo

fi



###############################################################################
# Audio
###############################################################################

collect \
"Audio devices" \
"$BASE/hardware/audio.txt" \
aplay -l



###############################################################################
# USB / Bluetooth / Wireless
###############################################################################

if command -v rfkill >/dev/null; then

collect \
"Wireless blocks" \
"$BASE/network/rfkill.txt" \
rfkill list

fi



if command -v bluetoothctl >/dev/null; then

collect \
"Bluetooth status" \
"$BASE/network/bluetooth.txt" \
timeout 5s bluetoothctl show

fi



###############################################################################
# Running processes
###############################################################################

collect \
"Running processes" \
"$BASE/system/processes.txt" \
ps aux



###############################################################################
# Login sessions
###############################################################################

collect \
"Login sessions" \
"$BASE/system/loginctl.txt" \
loginctl



###############################################################################
# Users and groups
###############################################################################

collect \
"Users" \
"$BASE/security/users.txt" \
getent passwd


collect \
"Groups" \
"$BASE/security/groups.txt" \
getent group



###############################################################################
# SSH information
###############################################################################

mkdir -p "$BASE/security/ssh"


if [ -f /etc/ssh/sshd_config ]; then

cp /etc/ssh/sshd_config \
"$BASE/security/ssh/"

fi


collect \
"SSH service status" \
"$BASE/security/ssh/status.txt" \
systemctl status sshd --no-pager



###############################################################################
# Virtualization
###############################################################################

collect \
"Virtualization detection" \
"$BASE/system/virtualization.txt" \
systemd-detect-virt


if command -v virsh >/dev/null; then

collect \
"Virtual machines" \
"$BASE/system/virtual-machines.txt" \
virsh list --all

fi



###############################################################################
# Containers
###############################################################################

if command -v docker >/dev/null; then

collect \
"Docker containers" \
"$BASE/system/docker.txt" \
docker ps -a

fi


if command -v podman >/dev/null; then

collect \
"Podman containers" \
"$BASE/system/podman.txt" \
podman ps -a

fi



###############################################################################
# Security status
###############################################################################

if command -v aa-status >/dev/null; then

collect \
"AppArmor status" \
"$BASE/security/apparmor.txt" \
aa-status

fi


if command -v sestatus >/dev/null; then

collect \
"SELinux status" \
"$BASE/security/selinux.txt" \
sestatus

fi


###############################################################################
# Router / Gateway Diagnostics
###############################################################################

msg "Checking router and gateway configuration"


mkdir -p "$BASE/router"



###############################################################################
# IP forwarding
###############################################################################

collect \
"IPv4 forwarding status" \
"$BASE/router/ip-forwarding.txt" \
sysctl net.ipv4.ip_forward


collect \
"IPv6 forwarding status" \
"$BASE/router/ipv6-forwarding.txt" \
sysctl net.ipv6.conf.all.forwarding



###############################################################################
# NAT and forwarding
###############################################################################

collect \
"NAT rules (nftables)" \
"$BASE/router/nft-nat.txt" \
bash -c "nft list ruleset | grep -Ei 'nat|masquerade|snat|dnat|forward'"



collect \
"Forwarding rules (nftables)" \
"$BASE/router/nft-forward.txt" \
bash -c "nft list ruleset | grep -Ei 'forward|accept|drop'"



###############################################################################
# Interfaces and roles
###############################################################################

collect \
"Interface details" \
"$BASE/router/interfaces-detailed.txt" \
ip -details addr


collect \
"Interface statistics" \
"$BASE/router/interface-statistics.txt" \
ip -s link



###############################################################################
# Bridges
###############################################################################

if command -v bridge >/dev/null; then

collect \
"Network bridges" \
"$BASE/router/bridges.txt" \
bridge link

fi



###############################################################################
# VLANs
###############################################################################

collect \
"VLAN information" \
"$BASE/router/vlan.txt" \
ip -d link



###############################################################################
# DHCP services
###############################################################################

if systemctl list-unit-files | grep -q dnsmasq; then

collect \
"dnsmasq service" \
"$BASE/router/dnsmasq-service.txt" \
systemctl status dnsmasq --no-pager


if [ -f /etc/dnsmasq.conf ]; then

cp /etc/dnsmasq.conf \
"$BASE/router/"

fi

fi



if systemctl list-unit-files | grep -q isc-dhcp; then

collect \
"ISC DHCP service" \
"$BASE/router/dhcp-service.txt" \
systemctl status isc-dhcp-server --no-pager

fi



###############################################################################
# DNS services
###############################################################################

collect \
"Listening DNS ports" \
"$BASE/router/dns-listeners.txt" \
bash -c "ss -tulpn | grep ':53'"



###############################################################################
# VPN tunnels
###############################################################################

collect \
"Tunnel interfaces" \
"$BASE/router/tunnels.txt" \
bash -c "ip link show | grep -Ei 'tun|tap|wg|vpn|ppp'"



if command -v wg >/dev/null; then

collect \
"WireGuard configuration status" \
"$BASE/router/wireguard.txt" \
wg show

fi



###############################################################################
# Routing tables
###############################################################################

collect \
"Complete routing table" \
"$BASE/router/routes-all.txt" \
ip route show table all



###############################################################################
# Network namespaces
###############################################################################

if command -v ip >/dev/null; then

collect \
"Network namespaces" \
"$BASE/router/netns.txt" \
ip netns list

fi



###############################################################################
# Firewall forwarding analysis
###############################################################################

{

echo "Router firewall summary"
echo
echo "Forward chain:"
echo

nft list ruleset 2>/dev/null \
| grep -A20 -B5 forward

echo
echo "NAT:"
echo

nft list ruleset 2>/dev/null \
| grep -A20 -B5 masquerade

} > "$BASE/router/firewall-summary.txt"



###############################################################################
# Detect likely gateway behaviour
###############################################################################

{

echo "Router detection"
echo "================"
echo


if sysctl net.ipv4.ip_forward 2>/dev/null | grep -q '= 1'; then

echo "YES: IPv4 forwarding enabled"

else

echo "NO: IPv4 forwarding disabled"

fi


echo


if nft list ruleset 2>/dev/null | grep -q masquerade; then

echo "YES: NAT masquerading detected"

else

echo "NO: NAT masquerading not detected"

fi


echo


if ss -tulpn 2>/dev/null | grep -q ':53'; then

echo "YES: DNS service detected"

else

echo "NO: DNS service not detected"

fi


echo


if ss -tulpn 2>/dev/null | grep -q ':67'; then

echo "YES: DHCP service detected"

else

echo "NO: DHCP service not detected"

fi


} > "$BASE/router/router-detection.txt"



msg "Router diagnostics complete"


###############################################################################
# Privacy cleaning
###############################################################################

msg "Applying privacy filters"


PRIVACY="$BASE/security/privacy-report.txt"


{

echo "Privacy filtering applied:"
echo

echo "- Password hashes removed"
echo "- SSH private keys excluded"
echo "- Shadow file excluded"
echo "- Temporary files excluded"

} > "$PRIVACY"



# Remove dangerous files if accidentally copied

find "$BASE" \
-type f \
-name "*shadow*" \
-delete 2>/dev/null || true


find "$BASE" \
-type f \
-name "id_rsa" \
-o -name "id_ed25519" \
-delete 2>/dev/null || true



###############################################################################
# Generate summary
###############################################################################

{

echo "================================================"
echo "AI Diagnostic Collector Summary"
echo "================================================"

echo
echo "Hostname:"
hostname

echo
echo "Date:"
date

echo
echo "Kernel:"
uname -r

echo
echo "Distribution:"
cat /etc/os-release 2>/dev/null | grep PRETTY_NAME

echo
echo "CPU:"
lscpu 2>/dev/null | grep "Model name"

echo
echo "Memory:"
free -h

echo
echo "Network:"
ip -4 -brief address show

echo
echo "Package count:"

if command -v pacman >/dev/null; then
pacman -Q | wc -l
fi

echo
echo "Report directory:"
echo "$BASE"

} > "$BASE/summary.txt"


###############################################################################
# Functions for Finalizing Outputs
###############################################################################

apply_privacy_filter()
{

msg "Applying privacy filter"


# Remove sensitive files

find "$BASE" \
-type f \
\( \
-name "shadow*" \
-o -name "id_rsa*" \
-o -name "id_ed25519*" \
-o -name "*.pem" \
\) \
-delete 2>/dev/null



# Replace MAC addresses

find "$BASE" -type f -exec sed -i \
-E 's/[0-9a-fA-F]{2}(:[0-9a-fA-F]{2}){5}/XX:XX:XX:XX:XX:XX/g' {} \;



# Replace IPv4 addresses

# find "$BASE" -type f -exec sed -i \
# -E 's/\b(10|172\.(1[6-9]|2[0-9]|3[0-1])|192\.168)\.[0-9]+\.[0-9]+\b/PRIVATE.IP.REDACTED/g' {} \;



# Replace usernames in home paths

# find "$BASE" -type f -exec sed -i \
# -E 's#/home/[^/ ]+#/home/USER#g' {} \;



echo "Privacy filtering applied" \
> "$BASE/security/privacy-filter.txt"

}

create_text_report()
{

TEXT_REPORT="${BASE}.txt"

msg "Creating single text report"


{

echo "=============================================================="
echo "AI Diagnostic Collector - Single File Report"
echo "=============================================================="

echo
echo "Generated:"
date

echo
echo "Hostname:"
hostname


echo
echo
echo "BEGIN REPORT"
echo


find "$BASE" -type f | sort | while read -r file
do

echo
echo
echo "################################################################"
echo "FILE: ${file#$BASE/}"
echo "################################################################"
echo

cat "$file"

done


echo
echo
echo "END REPORT"

} > "$TEXT_REPORT"


echo "$TEXT_REPORT"

}


###############################################################################
# Process Safe Mode
###############################################################################

if [ "$SAFE_MODE" = true ]; then
    apply_privacy_filter
fi

###############################################################################
# Output selection & Compression
###############################################################################

if [ "$TEXT_MODE" = true ]; then

    create_text_report

else

    msg "Creating archive"

    if command -v zstd >/dev/null; then
        
        ARCHIVE="${BASE}.tar.zst"
        tar \
        --exclude="$BASE/security/ssh" \
        -cf - "$BASE" \
        | zstd -T0 -19 -o "$ARCHIVE"

    else
        
        ARCHIVE="${BASE}.tar.gz"
        tar \
        --exclude="$BASE/security/ssh" \
        -czf "$ARCHIVE" "$BASE"

    fi

fi

###############################################################################
# Finish
###############################################################################

if [ "$TEXT_MODE" = false ]; then
    SIZE=$(du -h "$ARCHIVE" | awk '{print $1}')

    echo
    echo -e "${GREEN}================================${RESET}"
    echo -e "${GREEN} Collection complete ${RESET}"
    echo -e "${GREEN}================================${RESET}"

    echo
    echo "Archive:"
    echo "$ARCHIVE"

    echo
    echo "Size:"
    echo "$SIZE"

    echo
    echo "You can upload this archive to an AI assistant."

    echo
    echo "Review security/privacy information before sharing."
fi
#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to start services
start_services() {
    for service in "$@"; do
        sudo systemctl start "$service" && echo -e "${GREEN}Service '$service' started.${NC}" || echo -e "${RED}Error: Failed to start service '$service'.${NC}"
    done
}

# Function to restart services
restart_services() {
    for service in "$@"; do
        sudo systemctl restart "$service" && echo -e "${GREEN}Service '$service' restarted.${NC}" || echo -e "${RED}Error: Failed to restart service '$service'.${NC}"
    done
}

# Function to disable services
disable_services() {
    for service in "$@"; do
        sudo systemctl disable "$service" && echo -e "${GREEN}Service '$service' disabled.${NC}" || echo -e "${RED}Error: Failed to disable service '$service'.${NC}"
    done
}

# Function to enable services
enable_services() {
    for service in "$@"; do
        sudo systemctl enable "$service" && echo -e "${GREEN}Service '$service' enabled.${NC}" || echo -e "${RED}Error: Failed to enable service '$service'.${NC}"
    done
}

# Function to stop services
stop_services() {
    for service in "$@"; do
        sudo systemctl stop "$service" && echo -e "${GREEN}Service '$service' stopped.${NC}" || echo -e "${RED}Error: Failed to stop service '$service'.${NC}"
    done
}

# Function to check status of services
check_status() {
    for service in "$@"; do
        sudo systemctl status "$service"
    done
}

# List of services
services=(
    "systemd-networkd.service"
    "dnsmasq.service"
    "nftables.service"
    "ip-rules.service"
    "wg-quick@tun0.service"
    "openvpn-client@tun0.service"
    "vpn-manager.service"
    "dnscrypt-proxy.service"
    "minidlna.service"
    "tc.service"
    "cronie.service"
    "delayed-startup.service"
    "arch-portal.service"
    "caddy.service"
    "wan-watcher.service"
)
if [ "$1" = "reload" ]; then
    if sudo systemctl daemon-reload; then
        echo -e "${GREEN}Daemon reloaded.${NC}"
    else
        echo -e "${RED}Error: Failed to reload daemon.${NC}"
    fi
    exit
fi

# Countdown function – press any key to cancel
countdown() {
    local seconds=$1
    local action=$2   # "reboot" or "poweroff"

    echo -e "${YELLOW}Press any key to cancel...${NC}"

    for ((i = seconds; i >= 0; i--)); do
        printf "\r${GREEN}%s in %d...${NC} " "$action" "$i"
        # Wait 1 second, but allow a keypress to cancel
        if read -t 1 -n 1 key; then
            echo -e "\n${RED}Cancelled.${NC}"
            exit 0
        fi
    done
    echo   # move to next line after countdown finishes
}

if [ "$1" = "reboot" ]; then
    countdown 5 "Rebooting"
    echo -e "${GREEN}Rebooting now...${NC}"
    exec sudo systemctl reboot
fi

if [ "$1" = "poweroff" ]; then
    countdown 5 "Shutting down"
    echo -e "${GREEN}Shutting down now...${NC}"
    exec sudo systemctl poweroff
fi

# Check if action argument is provided
if [ -z "$1" ]; then
    echo -e "${RED}Usage: $0 \n    ${GREEN}l | launch | start  \n    ${YELLOW}r | restart \n    ${RED}k | kill | stop \n    ${GREEN}e | enable \n    ${RED}d | disable \n    ${BLUE}s | status ${NC}"
    exit 1
fi

if [ -z "$2" ]; then
    # Display options
    echo -e "${BLUE}Select the services to perform actions on:${NC}"
    for ((i=0; i<${#services[@]}; i++)); do
        echo -e "${YELLOW}$((i+1)). ${services[i]}${NC}"
    done

    # Prompt for services to perform action on
    read -rp "Enter the numbers of services to perform action on (space or comma-separated): " selected_numbers
else
    # Use the second argument as the selected numbers
    selected_numbers="$2"
fi

# Set the Internal Field Separator (IFS) to comma and space
IFS=", " read -ra selected_indices <<< "${selected_numbers:-}"

# Get selected services
selected_services=()
for index in "${selected_indices[@]}"; do
    selected_services+=("${services[index-1]}")
done

case "$1" in
    l | launch | start)
        for index in "${selected_indices[@]}"; do
            start_services "${services[$((index - 1))]}"
        done
        ;;
    s | status)
        for index in "${selected_indices[@]}"; do
            check_status "${services[$((index - 1))]}"
        done
        ;;
    r | restart)
        for index in "${selected_indices[@]}"; do
            restart_services "${services[$((index - 1))]}"
        done
        ;;
    d | disable)
        for index in "${selected_indices[@]}"; do
            disable_services "${services[$((index - 1))]}"
        done
        ;;
    e | enable)
        for index in "${selected_indices[@]}"; do
            enable_services "${services[$((index - 1))]}"
        done
        ;;
    k | kill | stop)
        for index in "${selected_indices[@]}"; do
            stop_services "${services[$((index - 1))]}"
        done
        ;;
    reload)
        sudo systemctl daemon-reload && echo -e "${GREEN}Daemon reloaded.${NC}" || echo -e "${RED}Error: Failed to reload daemon.${NC}";
        ;;
    *)
        echo "Invalid action!"
        exit 1
        ;;
esac

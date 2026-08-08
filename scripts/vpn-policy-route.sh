#!/usr/bin/env bash
#
# Secondary VPN policy route manager
#
# Purpose:
#   Build policy routing rules for selected destination ranges
#   through the secondary VPN interface.
#
# This script does NOT manage VPN connections.
# It only manages routing policy.
#

set -euo pipefail


#######################################
# Configuration
#######################################

SCRIPT_NAME="vpn-policy-route"

TABLE_NAME="vpn"
VPN_INTERFACE="tun1"

# Destination prefix list
DESTINATION_NAME="Tun1-IP-Ranges"
IP_LIST_FILE="/opt/router/scripts/vpniplist.txt"

# LAN route preservation
LAN_INTERFACE="lan"
LAN_NETWORK="172.22.0.0/24"
LAN_IP="172.22.0.1"

# Policy rule priority range
START_PRIORITY=4000


#######################################
# Logging
#######################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'


log()
{
    local level="$1"
    local message="$2"

    logger -t "$SCRIPT_NAME" "$level: $message"

    case "$level" in
        INFO)
            echo -e "${BLUE}[INFO]${NC} $message"
            ;;
        OK)
            echo -e "${GREEN}[OK]${NC} $message"
            ;;
        WARN)
            echo -e "${YELLOW}[WARN]${NC} $message"
            ;;
        ERROR)
            echo -e "${RED}[ERROR]${NC} $message"
            ;;
    esac
}


#######################################
# Remove existing rules owned by us
#######################################

remove_existing_rules()
{
log INFO "Removing existing $TABLE_NAME policy rules."

while true; do

    RULE=$(ip rule show | grep "lookup $TABLE_NAME" | head -n1 || true)

    if [ -z "$RULE" ]; then
        break
    fi

    PRIORITY=$(echo "$RULE" | awk -F: '{print $1}')

    ip rule del priority "$PRIORITY"

    log INFO "Removed rule priority $PRIORITY."

done
}
#######################################
# Validate prefix list
#######################################

check_ip_list()
{
    if [ ! -f "$IP_LIST_FILE" ]; then
        log ERROR "Destination list missing: $IP_LIST_FILE"
        exit 1
    fi
}


#######################################
# Configure routing table
#######################################

configure_table()
{
    log INFO "Configuring routing table '$TABLE_NAME' for secondary VPN interface '$VPN_INTERFACE'."

    if ! ip route show table "$TABLE_NAME" 2>/dev/null \
        | grep -q "default dev $VPN_INTERFACE"; then

        ip route replace \
            default \
            dev "$VPN_INTERFACE" \
            table "$TABLE_NAME"

        log OK "Default route added via $VPN_INTERFACE."

    else
        log WARN "Default route already exists."
    fi


    if ! ip route show table "$TABLE_NAME" 2>/dev/null \
        | grep -q "$LAN_NETWORK dev $LAN_INTERFACE"; then

        ip route replace \
            "$LAN_NETWORK" \
            dev "$LAN_INTERFACE" \
            src "$LAN_IP" \
            table "$TABLE_NAME"

        log OK "LAN route added."

    else
        log WARN "LAN route already exists."
    fi
}


#######################################
# Add destination rules
#######################################

configure_destination_rules()
{
    log INFO "Loading destination prefixes from $IP_LIST_FILE ($DESTINATION_NAME)."

    CURRENT_PRIORITY=$START_PRIORITY

    while IFS= read -r IP_RANGE; do

        IP_RANGE=$(echo "$IP_RANGE" | tr -d '[:space:]')

        if [ -z "$IP_RANGE" ]; then
            continue
        fi

        if [[ "$IP_RANGE" == \#* ]]; then
            continue
        fi


        if ip rule show | grep -q \
            "to $IP_RANGE lookup $TABLE_NAME"; then

            log WARN "Rule already exists: $IP_RANGE"

        else

            ip rule add \
                priority "$CURRENT_PRIORITY" \
                from all \
                to "$IP_RANGE" \
                lookup "$TABLE_NAME"

            log OK "Added rule: $CURRENT_PRIORITY -> $IP_RANGE -> $TABLE_NAME"

        fi


        CURRENT_PRIORITY=$((CURRENT_PRIORITY + 1))

    done < "$IP_LIST_FILE"
}


#######################################
# Main
#######################################

log INFO "Starting secondary VPN destination routing configuration."

remove_existing_rules

check_ip_list

configure_table

configure_destination_rules

log OK "Secondary VPN destination routing configuration completed successfully."

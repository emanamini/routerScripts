#!/bin/bash

# Specify the absolute path for the temporary file
TEMP_FILE="/opt/router/Scripts/temp_ip_list.txt"

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the IP address of the LAN interface
#lanIP=$(ip addr show lan | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
lanIP=$(ip -4 -o addr show dev lan 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -n 1)
firstThreeOctets=$(echo "$lanIP" | cut -d '.' -f 1-3)

# Get the Gateway Address of WAN Interface
wanGateway=$(ip route show dev wan | grep -oP 'default via \K\S+' | head -n 1)

# Specify the interface and gateway
INTERFACE="wan"
TABLE_NAME="irtr"

# Function to extract IP addresses from domains and save them to a temporary file
extract_ip_addresses() {
    # Clean up the temporary file before extracting new IP addresses
    rm -f "$TEMP_FILE"

    while IFS= read -r domain; do
        # Resolve domain to IP addresses
        dig +short "@$wanGateway" "$domain" | while read -r ip; do
            # Validate the format of the IP address (four blocks)
            if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                # Check if the IP address is not loopback, private, or related to your machine
                if ! [[ "$ip" =~ ^127\.0\.|^10\.\11\.11\.|^192\.168\. ]]; then
                    echo "$ip" >> "$TEMP_FILE"
                else
                    echo "Skipping $ip as it is loopback, private, or related to your machine."
                fi
            else
                echo "Skipping $ip as it does not have a valid format (four blocks)."
            fi
        done
    done < /opt/router/Scripts/irdomains.txt

    # Remove duplicate IP addresses and lines that don't contain IP addresses
    awk '!seen[$0]++ && /([0-9]+\.){3}[0-9]+/' "$TEMP_FILE" > "$TEMP_FILE.tmp" && mv "$TEMP_FILE.tmp" "$TEMP_FILE"

    echo "IP addresses extracted and saved to $TEMP_FILE."
}

# Function to add routing rules based on the extracted IP addresses
add_routing_rules() {
    # Check if the temporary file exists
    if [ ! -f "$TEMP_FILE" ]; then
        echo "Temporary file $TEMP_FILE not found. Exiting."
        exit 1
    fi
    # Check if the route already exists before adding it
    if ! ip route show table "$TABLE_NAME" | grep -q "default via $wanGateway dev $INTERFACE"; then
        ip route add default via "$wanGateway" dev "$INTERFACE" table "$TABLE_NAME" && echo "Route for default added."
    else
        echo "Route for $TABLE_NAME already exists. Skipping."
    fi
    
    # Read IP addresses from the temporary file and add routing rules
    while IFS= read -r ip; do
        # Check if the rule for the IP address already exists
        if ip rule show | grep -q "$ip lookup $TABLE_NAME"; then
            echo "Rule for $ip already exists. Skipping."
        else
            # Add rule for each IP address
            ip rule add from all to "$ip" lookup "$TABLE_NAME" && echo "Rule for $ip added."
        fi
    done < "$TEMP_FILE"

    echo "Routing rules added based on IP addresses in $TEMP_FILE."

}

# Function to add IP rules based on CIDR IP ranges from a file
add_irlist() {
    # Path to the file containing CIDR IP ranges
    IP_LIST_FILE="/opt/router/Scripts/iriplist.txt"

    # Check if the IP list file exists
    if [ ! -f "$IP_LIST_FILE" ]; then
        echo "Error: IP list file '$IP_LIST_FILE' not found."
        exit 1
    fi

    # Check if the route already exists before adding it
    if ! ip route show table "$TABLE_NAME" | grep -q "default via $wanGateway dev $INTERFACE"; then
        ip route add default via "$wanGateway" dev "$INTERFACE" table "$TABLE_NAME" && echo "Route for default added."
    else
        echo "Route for $TABLE_NAME already exists. Skipping."
    fi
    
    # Read each line (IP range) from the file
    while IFS= read -r IP_RANGE; do
        # Trim any leading/trailing whitespace
        IP_RANGE=$(echo "$IP_RANGE" | tr -d '[:space:]')

        # Add the IP rule for the current IP range
        if ! ip rule show | grep -q "$IP_RANGE"; then
            ip rule add from all to "$IP_RANGE" lookup "$TABLE_NAME" && echo "Rule for $IP_RANGE added."
        else
            echo "Rule for $IP_RANGE already exists."
        fi
    done < "$IP_LIST_FILE"
}

# Check the command-line argument and execute the corresponding action
if [ "$1" == "extract" ] || [ "$1" == "e" ]; then
    extract_ip_addresses
elif [ "$1" == "apply" ] || [ "$1" == "a" ]; then
    add_routing_rules
elif [ "$1" == "irlist" ] || [ "$1" == "i" ]; then
    add_irlist
else
    echo  -e "${RED}Usage: ./irtr.sh \n ${GREEN}    extract | e \n ${BLUE}    apply   | a \n ${YELLOW}    irlist  | i${NC}"
    exit 1
fi

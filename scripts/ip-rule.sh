#!/bin/bash

# Set variables for the second script
TABLE_NAME="irtr"
PRIORITY=3900      # Initial priority value

# Get the IP address of the LAN interface
#lanIP=$(ip addr show lan | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
lanIP=$(ip -4 -o addr show dev lan 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -n 1)
firstThreeOctets=$(echo "$lanIP" | cut -d '.' -f 1-3)

# Get the Gateway Address of WAN Interface
wanGateway=$(ip route show dev wan | grep -oP 'default via \K\S+' | head -n 1)

# Add default route for the specified table
ip route replace default via "$wanGateway" dev wan table "$TABLE_NAME"

# Loop through IP addresses and add rules for the specified table
for i in 139 241 242 243 244 245 127 144 130 192; do
    j=1
    varCount=$(sudo /usr/bin/ip rule show all | grep -c "$firstThreeOctets.$i")
    while [[ $j -le $varCount ]]; do
        sudo ip rule del from "$firstThreeOctets.$i" table "$TABLE_NAME"
        ((j = j + 1))
    done
    ip rule add from "$firstThreeOctets.$i" table "$TABLE_NAME" prio "$PRIORITY"
    echo "Adding rule for $firstThreeOctets.$i with priority $PRIORITY"
    ((PRIORITY--))  # Decrement the priority value
done

# Execute the specified script with argument 'irlist'
/opt/router/scripts/irtr.sh irlist


# Flush the route cache
ip route flush cache

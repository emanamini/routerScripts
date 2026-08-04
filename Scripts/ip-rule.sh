#!/bin/bash


# Set variables for the second script
TABLE_NAME="irtr"
PRIORITY=7998      # Initial priority value

# Get the IP address of the LAN interface
#lanIP=$(ip addr show lan | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
lanIP=$(ip -4 -o addr show dev lan 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -n 1)
firstThreeOctets=$(echo "$lanIP" | cut -d '.' -f 1-3)

# Get the Gateway Address of WAN Interface
wanGateway=$(ip route show dev wan | grep -oP 'default via \K\S+' | head -n 1)

# Delete specific IP rules and routes PS5
# ip rule del prio 100 from "$firstThreeOctets.173" to "$firstThreeOctets.124"
# ip rule del prio 101 from "$firstThreeOctets.124" to "$firstThreeOctets.173"
# ip route del "$firstThreeOctets.173" via "$lanIP" dev lan
# ip route del "$firstThreeOctets.124" via "$lanIP" dev lan

# Add default route for the specified table
ip route replace default via "$wanGateway" dev wan table "$TABLE_NAME"

# Loop through IP addresses and add rules for the specified table
for i in 241 242 243 244 245; do
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

# Execute the specified script with argument 'irlist', you can change it to "a" for specific domains listed in the irdomains.txt after running once with "e" to extract the ip addresses
/opt/router/Scripts/irtr.sh irlist

# Add rules to specify when to use the custom routing table PS5
# ip rule add prio 100 from "$firstThreeOctets.173" to "$firstThreeOctets.124"
# ip rule add prio 101 from "$firstThreeOctets.124" to "$firstThreeOctets.173"
# ip route add "$firstThreeOctets.173" via "$lanIP" dev lan
# ip route add "$firstThreeOctets.124" via "$lanIP" dev lan



# Flush the route cache
ip route flush cache

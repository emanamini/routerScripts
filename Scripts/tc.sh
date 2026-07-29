#!/bin/bash

# Path to the tc binary
TC=$(which tc)

# Specify the network interface
INTERFACE="lan"

# Get the IP address of the LAN interface dynamically
lanIP=$(ip addr show "$INTERFACE" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

if [ -z "$lanIP" ]; then
    echo "Error: Could not detect IP on interface $INTERFACE"
    exit 1
fi

firstThreeOctets=$(echo "$lanIP" | cut -d '.' -f 1-3)

# 1. Clean up existing qdisc rules to prevent duplicates
$TC qdisc del dev $INTERFACE root 2>/dev/null

# 2. Set up the HTB root to allow us to split "unthrottled" vs "throttled" traffic
$TC qdisc add dev $INTERFACE root handle 1: htb default 10

# Class 1:10 -> Default throttled class (e.g., set to 150mbit or whatever your limit is)
# Adjust the rate "150mbit" below to match your desired limit for normal users!
$TC class add dev $INTERFACE parent 1: classid 1:10 htb rate 150mbit ceil 150mbit

# Class 1:20 -> Unthrottled class (up to full 1Gbps link speed)
$TC class add dev $INTERFACE parent 1: classid 1:20 htb rate 1000mbit

# 3. Apply CAKE on the throttled class (1:10) to make sure bandwidth is shared perfectly
# "triple-isolate" dynamically balances bandwidth per-host and per-connection
$TC qdisc add dev $INTERFACE parent 1:10 handle 10: cake triple-isolate nonat besteffort

# 4. Apply a standard fast queue (fq_codel) on the unthrottled class (1:20)
$TC qdisc add dev $INTERFACE parent 1:20 handle 20: fq_codel

# 5. Route your skip list to the unthrottled class (1:20)
skip_numbers=(110 116 200 201 202 203 204)

echo "Applying CAKE and HTB Traffic Control..."

for num in "${skip_numbers[@]}"; do
    target_ip="$firstThreeOctets.$num"
    echo "Directing $target_ip to Unthrottled Engine"
    
    # Route traffic destined to/from this host straight to the 1Gbps unthrottled class
    $TC filter add dev $INTERFACE protocol ip parent 1: prio 1 u32 match ip dst "$target_ip" flowid 1:20
    $TC filter add dev $INTERFACE protocol ip parent 1: prio 1 u32 match ip src "$target_ip" flowid 1:20
done

echo "----------------------------------------"
echo "CAKE Flow Isolation active on default pool."
echo "----------------------------------------"

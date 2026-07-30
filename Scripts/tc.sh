#!/bin/bash
TC=$(which tc)
INTERFACE="lan"

lanIP=$(ip -4 addr show "$INTERFACE" | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n 1)
if [ -z "$lanIP" ]; then
    echo "Error: Could not detect IPv4 on $INTERFACE"
    exit 1
fi
firstThreeOctets=$(echo "$lanIP" | cut -d. -f1-3)

# Cleanup
$TC qdisc del dev $INTERFACE root 2>/dev/null

# Root HTB
$TC qdisc add dev $INTERFACE root handle 1: htb default 10

# Intermediate class representing full link speed (recommended)
$TC class add dev $INTERFACE parent 1: classid 1:1 htb rate 1000mbit ceil 1000mbit

# Throttled class
$TC class add dev $INTERFACE parent 1:1 classid 1:10 htb rate 150mbit ceil 150mbit
$TC qdisc add  dev $INTERFACE parent 1:10 handle 10: cake triple-isolate nonat besteffort

# Unthrottled class
$TC class add dev $INTERFACE parent 1:1 classid 1:20 htb rate 1000mbit ceil 1000mbit
$TC qdisc add  dev $INTERFACE parent 1:20 handle 20: fq_codel

# Skip list
skip_numbers=(110 116 200 201 202 203 204)
for num in "${skip_numbers[@]}"; do
    target_ip="$firstThreeOctets.$num"
    echo "→ Unthrottled: $target_ip"
    $TC filter add dev $INTERFACE protocol ip parent 1: prio 1 u32 \
        match ip dst "$target_ip" flowid 1:20
    $TC filter add dev $INTERFACE protocol ip parent 1: prio 1 u32 \
        match ip src "$target_ip" flowid 1:20
done

echo "Done. CAKE triple-isolate on default pool, selected hosts unrestricted."

#!/bin/bash

# Check if the user provided an IP address as the first parameter
if [ -z "$1" ]; then
    echo "Usage: ./domain-harvest.sh client-ip-address"
    echo "Example: ./domain-harvest.sh 172.22.0.116"
    exit 1
fi

# Assign the first parameter to our IP variable
CLIENT_IP="$1"
LOG_FILE="domain-query.log"

# 1. Clear the previous log file by overriding it with nothing
> "$LOG_FILE"

echo "Harvesting live DNS queries for $CLIENT_IP..."
echo "Saving unique domains to $LOG_FILE (Press Ctrl+C to stop)"
echo "--------------------------------------------------------"

# 2. Stream logs, filter, extract, and deduplicate in real-time
sudo journalctl -fu dnsmasq | \
grep --line-buffered "$CLIENT_IP" | \
grep --line-buffered -oP "query\[[A-Z]+\] \K[^ ]+" | \
awk -v logfile="$LOG_FILE" '!seen[$0]++ {
    # Print to the terminal so you can watch it live
    print $0
    # Append to the log file and force it to save immediately
    print $0 >> logfile
    fflush(logfile)
}'

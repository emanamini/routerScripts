#!/usr/bin/env bash
# /opt/router/Scripts/wan-watcher.sh
# Native kernel monitor for WAN link state and routing policy validation

TABLE_NAME="irtr"
WAN_IFACE="wan"
DEBOUNCE_SECONDS=3
LAST_RESTART=0

# Listen directly to kernel for link, IP address, and route changes.
while IFS= read -r event; do

    NOW=$(date +%s)

    # 1. Rate-limit: Only process events if we haven't recently triggered a recovery
    if (( NOW - LAST_RESTART >= DEBOUNCE_SECONDS )); then

        # 2. Let the dust settle (DHCP negotiation, IPv6 SLAAC, etc.)
        sleep "$DEBOUNCE_SECONDS"

        # 3. Validation: Check if the route output is EMPTY (-z).
        # (ip route show always exits with 0, so we must check the actual output string)
        if [[ -z "$(ip route show table "$TABLE_NAME" default dev "$WAN_IFACE" 2>/dev/null)" ]]; then

            # 4. Update timestamp BEFORE the restart to close the race condition window
            LAST_RESTART=$(date +%s)

            logger -t wan-watcher "Network event detected. '$TABLE_NAME' default route missing. Restarting ip-rules.service..."

            # 5. Execute restart and explicitly log the outcome
            if systemctl restart ip-rules.service; then
                logger -t wan-watcher "ip-rules.service restarted successfully."
            else
                logger -p daemon.err -t wan-watcher "Failed to restart ip-rules.service."
            fi
        fi
    fi

done < <(ip monitor link address route dev "$WAN_IFACE")

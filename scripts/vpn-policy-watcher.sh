#!/usr/bin/env bash
# /opt/router/scripts/vpn-policy-watcher.sh
#
# Secondary VPN supervisor
# Does NOT manage default route or primary VPN.
#

set -u

CONF_FILE="/etc/vpn-watcher.conf"
STATUS_FILE="/run/vpn-watcher.status"
LOCK_FILE="/run/vpn-watcher.lock"

if ! exec 200>"$LOCK_FILE"; then
    logger -p daemon.err -t vpn-watcher \
        "Cannot create lock file: $LOCK_FILE"
    exit 1
fi

if ! flock -n 200; then
    logger -t vpn-watcher "Another instance is already running."
    exit 0
fi

if [ ! -f "$CONF_FILE" ]; then
    logger -p daemon.err -t vpn-watcher \
        "Missing configuration: $CONF_FILE"
    exit 1
fi

source "$CONF_FILE"

: "${CHECK_INTERVAL:=30}"
: "${VPN_START_TIMEOUT:=30}"
: "${WIREGUARD_MAX_HANDSHAKE_AGE:=300}"
: "${MAX_RECOVERY_ATTEMPTS:=5}"
: "${COOLDOWN_PERIOD:=1800}"
: "${MONITOR_ONLY:=yes}"

cleanup_other_vpn()
{
    if [ "$VPN_TYPE" = "openvpn" ]; then
        OTHER_SERVICE="$WIREGUARD_SERVICE"
    else
        OTHER_SERVICE="$OPENVPN_SERVICE"
    fi

    if systemctl is-active --quiet "$OTHER_SERVICE"; then
        log "Stopping inactive secondary VPN service: $OTHER_SERVICE"
        systemctl stop "$OTHER_SERVICE"
    fi
}

log()
{
    logger -t vpn-watcher "$1"
}


update_status()
{
    cat > "$STATUS_FILE" <<EOF
VPN_TYPE=$VPN_TYPE
INTERFACE=$VPN_INTERFACE
STATE=$1
TIME=$(date '+%Y-%m-%d %H:%M:%S')
RECOVERY_COUNT=${RECOVERY_COUNT:-0}
EOF
}


get_service()
{
    if [ "$VPN_TYPE" = "openvpn" ]; then
        echo "$OPENVPN_SERVICE"
    else
        echo "$WIREGUARD_SERVICE"
    fi
}


wait_for_tunnel()
{
    local elapsed=0

    while [ "$elapsed" -lt "$VPN_START_TIMEOUT" ]; do
        if ip addr show "$VPN_INTERFACE" 2>/dev/null \
            | grep -q "inet "; then
            return 0
        fi

        sleep 1
        elapsed=$((elapsed + 1))
    done

    return 1
}


check_service()
{
    local service
    service=$(get_service)

    systemctl is-active --quiet "$service"
}


check_interface()
{
    ip link show "$VPN_INTERFACE" >/dev/null 2>&1
}


check_ip()
{
    ip addr show "$VPN_INTERFACE" 2>/dev/null \
        | grep -q "inet "
}


check_wireguard_handshake()
{
    [ "$VPN_TYPE" = "wireguard" ] || return 0

    local latest

    latest=$(wg show "$VPN_INTERFACE" latest-handshakes \
        2>/dev/null | awk '{print $2}' | sort -nr | head -1)

    if [ -z "$latest" ] || [ "$latest" = "0" ]; then
        return 1
    fi

    local now age

    now=$(date +%s)
    age=$((now - latest))

    if [ "$age" -gt "$WIREGUARD_MAX_HANDSHAKE_AGE" ]; then
        return 1
    fi

    return 0
}


check_route()
{
local result
local rule_count

result=$(ip route show table "$TABLE_NAME" 2>/dev/null)

if ! echo "$result" | grep -q "default dev $VPN_INTERFACE"; then
    return 1
fi

rule_count=$(ip rule show | grep -c "lookup $TABLE_NAME" || true)

if [ "$rule_count" -lt 10 ]; then
    return 1
fi

return 0
}
restore_routes()
{
    if [ -x "$ROUTE_RESTORE_SCRIPT" ]; then

        log "Starting secondary VPN route restoration: $ROUTE_RESTORE_SCRIPT"

        if "$ROUTE_RESTORE_SCRIPT"; then
            log "Secondary VPN route restoration completed successfully."
            return 0
        else
            log "Secondary VPN route restoration failed."
            return 1
        fi

    else
        log "Route restore script missing or not executable: $ROUTE_RESTORE_SCRIPT"
        return 1
    fi
}


health_check()
{
    if ! check_service; then
        log "Health check failed: VPN service inactive."
        return 1
    fi

    if ! check_interface; then
        log "Health check failed: interface $VPN_INTERFACE missing."
        return 1
    fi

    if ! check_ip; then
        log "Health check failed: interface $VPN_INTERFACE has no IP address."
        return 1
    fi

    if ! check_wireguard_handshake; then
        log "Health check failed: WireGuard handshake expired or missing."
        return 1
    fi

    if ! check_route; then
        log "Health check failed: policy route through $VPN_INTERFACE missing."
        return 2
    fi

    return 0
}


restart_vpn()
{
    local service

    service=$(get_service)

    log "Restarting secondary VPN: $service"

    systemctl restart "$service"

    if wait_for_tunnel; then
        log "Tunnel restored."

        sleep 3

        restore_routes

        return 0
    else
        log "Tunnel failed to return."
        return 1
    fi
}


RECOVERY_COUNT=0

update_status "Starting"

log "Config loaded: VPN_TYPE=$VPN_TYPE MONITOR_ONLY=$MONITOR_ONLY"
log "Watching interface: $VPN_INTERFACE"
log "vpn-watcher started."


while true; do

    health_check
    result=$?

    if [ "$result" -eq 0 ]; then
        RECOVERY_COUNT=0
        update_status "Healthy"

        sleep "$CHECK_INTERVAL"
        continue
    fi


    log "VPN health failure detected."


    #
    # Absolutely no recovery in monitor-only mode.
    #

    if [ "$MONITOR_ONLY" = "yes" ]; then

        if [ "$result" -eq 2 ]; then
            log "VPN alive but policy route missing."
        fi

        log "Monitor-only mode enabled. No recovery action taken."

        update_status "Degraded (Monitor Only)"

        sleep "$CHECK_INTERVAL"
        continue
    fi


    #
    # Route-only failure
    #

    if [ "$result" -eq 2 ]; then

        log "VPN alive but policy route missing."

        if restore_routes; then
            update_status "Healthy"
            RECOVERY_COUNT=0
        else
            update_status "Route Recovery Failed"
        fi

        sleep "$CHECK_INTERVAL"
        continue
    fi


    update_status "Degraded"


    if [ "$RECOVERY_COUNT" -ge "$MAX_RECOVERY_ATTEMPTS" ]; then

        log "Maximum recovery reached. Cooling down."

        update_status "Cooldown"

        sleep "$COOLDOWN_PERIOD"

        RECOVERY_COUNT=0

        continue
    fi


    RECOVERY_COUNT=$((RECOVERY_COUNT + 1))


    if restart_vpn; then
        RECOVERY_COUNT=0
        update_status "Healthy"
    else
        update_status "Recovery Failed"
    fi


    sleep "$CHECK_INTERVAL"

done

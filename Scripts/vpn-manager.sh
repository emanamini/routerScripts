#!/bin/bash
# ====================================================================
# Arch Linux Router - DNSCrypt + OpenVPN + WireGuard Supervisor v5.1
# ====================================================================

CONF_FILE="/etc/vpn-manager.conf"
STATUS_FILE="/run/vpn-manager.status"

# ---------------------------------------------------------
# PROCESS LOCKING
# ---------------------------------------------------------
LOCK_FILE="/run/vpn-manager.lock"
exec 200>"$LOCK_FILE"
if ! flock -n 200; then
    echo "[FATAL] Another instance of vpn-manager is already running."
    exit 1
fi

# ---------------------------------------------------------
# LOAD & VALIDATE CONFIGURATION
# ---------------------------------------------------------
if [ -f "$CONF_FILE" ]; then
    source "$CONF_FILE"
else
    echo "[FATAL] Configuration file missing: $CONF_FILE"
    exit 1
fi

: "${VPN_START_TIMEOUT:=30}"
: "${ROUTE_TEST_IP:=8.8.8.8}"
: "${WIREGUARD_MAX_HANDSHAKE_AGE:=300}"
: "${MAX_RECOVERY_ATTEMPTS:=5}"
: "${COOLDOWN_PERIOD:=1800}"
: "${MONITOR_ONLY:=yes}"

log() {
    local level="$1"
    local msg="$2"
    echo "[$level] $msg"
}

update_status() {
    local current_state="$1"
    cat <<EOF > "$STATUS_FILE"
VPN=$VPN_TYPE
STATE=$current_state
LAST_CHECK=$(date '+%Y-%m-%d %H:%M:%S')
RECOVERY_COUNT=${recovery_count:-0}
EOF
}

if [ "$VPN_TYPE" != "openvpn" ] && [ "$VPN_TYPE" != "wireguard" ]; then
    log "FATAL" "Invalid VPN_TYPE: '$VPN_TYPE'. Must be 'openvpn' or 'wireguard'."
    exit 1
fi

# ---------------------------------------------------------
# HELPER FUNCTIONS
# ---------------------------------------------------------
wait_for_tunnel() {
    local elapsed=0
    while [ $elapsed -lt "$VPN_START_TIMEOUT" ]; do
        if ip addr show "$TUN_INTERFACE" 2>/dev/null | grep -q "inet "; then
            return 0
        fi
        sleep 1
        elapsed=$((elapsed + 1))
    done
    return 1
}

# ---------------------------------------------------------
# HEALTH CHECK FUNCTIONS
# ---------------------------------------------------------
check_dns() {
    local result
    # We pipe through grep to remove all comment/error lines that start with ';'
    result=$(dig "@$DNS_SERVER" -p "$DNS_PORT" "$DNS_TEST_DOMAIN" +time=5 +tries=1 +short 2>/dev/null | grep -v '^[;]')
    if [ -n "$result" ]; then return 0; else return 1; fi
}

check_vpn_state() {
    local srv_name
    if [ "$VPN_TYPE" == "openvpn" ]; then
        srv_name="$OPENVPN_SERVICE"
    else
        srv_name="$WIREGUARD_SERVICE"
    fi

    if ! systemctl is-active --quiet "$srv_name"; then
        echo "Service $srv_name inactive"
        return 1
    fi

    if ! ip link show "$TUN_INTERFACE" >/dev/null 2>&1; then
        echo "Interface $TUN_INTERFACE missing"
        return 1
    fi

    if ! ip addr show "$TUN_INTERFACE" | grep -q "inet "; then
        echo "No IP address on $TUN_INTERFACE"
        return 1
    fi

    if ! ip route get "$ROUTE_TEST_IP" 2>/dev/null | grep -q "dev $TUN_INTERFACE"; then
        echo "Route missing (traffic bypassing $TUN_INTERFACE)"
        return 1
    fi

    if [ "$VPN_TYPE" == "wireguard" ]; then
        local latest_hs
        latest_hs=$(wg show "$TUN_INTERFACE" latest-handshakes 2>/dev/null | awk '{print $2}' | sort -nr | head -n 1)
        
        if [ -z "$latest_hs" ] || [ "$latest_hs" -eq 0 ]; then
            echo "WireGuard has no successful handshakes yet"
            return 1
        fi
        
        local current_time=$(date +%s)
        local age=$((current_time - latest_hs))
        
        if [ "$age" -lt 0 ]; then age=0; fi
        
        if [ "$age" -gt "$WIREGUARD_MAX_HANDSHAKE_AGE" ]; then
            echo "WireGuard handshake too old (${age}s > ${WIREGUARD_MAX_HANDSHAKE_AGE}s)"
            return 1
        fi
    fi

    echo "OK"
    return 0
}

check_internet_tun() {
    if curl --interface "$TUN_INTERFACE" -I --connect-timeout 10 -s "https://example.com" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

run_all_checks() {
    local dns_ok=true inet_ok=true vpn_ok=true
    local vpn_err="" inet_err="" dns_err=""

    if ! check_dns; then 
        dns_ok=false
        dns_err="DNS lookup via $DNS_SERVER:$DNS_PORT failed"
    fi

    vpn_err=$(check_vpn_state)
    if [ "$vpn_err" != "OK" ]; then 
        vpn_ok=false
    fi

    if [ "$vpn_ok" = true ]; then
        if ! check_internet_tun; then 
            inet_ok=false
            inet_err="Curl through $TUN_INTERFACE failed"
        fi
    else
        inet_ok=false
        inet_err="Skipped (Interface/Routes not ready)"
    fi

    if [ "$dns_ok" = true ] && [ "$inet_ok" = true ] && [ "$vpn_ok" = true ]; then
        return 0 
    else
        log "WARN" "Health check failed!"
        log "WARN" " -> DNS State:      ${dns_err:-OK}"
        log "WARN" " -> VPN State:      ${vpn_err}"
        log "WARN" " -> Internet (tun): ${inet_err:-OK}"
        return 1 
    fi
}

# ---------------------------------------------------------
# BOOT/STARTUP LOGIC
# ---------------------------------------------------------
update_status "Booting"
log "INFO" "Starting vpn-manager (Type: $VPN_TYPE, Monitor Only: $MONITOR_ONLY)"

if ! systemctl is-active --quiet "$DNSCRYPT_SERVICE"; then
    systemctl start "$DNSCRYPT_SERVICE"
    sleep 2
fi

dns_attempts=0
while ! check_dns; do
    dns_attempts=$((dns_attempts + 1))
    if [ $dns_attempts -ge 3 ]; then
        log "FATAL" "DNSCrypt failed to resolve via $DNS_SERVER:$DNS_PORT after 3 attempts. Aborting VPN startup."
        update_status "Fatal - DNS Failure"
        exit 1
    fi
    log "WARN" "DNS failure detected on startup, restarting dnscrypt-proxy..."
    systemctl restart "$DNSCRYPT_SERVICE"
    sleep 2
done

log "OK" "DNSCrypt operational. DNS resolution successful."

if [ "$VPN_TYPE" == "openvpn" ]; then
    log "INFO" "Starting OpenVPN ($OPENVPN_SERVICE)"
    systemctl start "$OPENVPN_SERVICE"
elif [ "$VPN_TYPE" == "wireguard" ]; then
    log "INFO" "Starting WireGuard ($WIREGUARD_SERVICE)"
    systemctl start "$WIREGUARD_SERVICE"
fi

if wait_for_tunnel; then
    log "OK" "Tunnel $TUN_INTERFACE established successfully."
    sleep 2
else
    log "WARN" "Tunnel $TUN_INTERFACE did not appear within $VPN_START_TIMEOUT seconds. Entering health loop."
fi

# ---------------------------------------------------------
# PERIODIC HEALTH MONITORING & RECOVERY LOOP
# ---------------------------------------------------------
recovery_count=0

while true; do
    if run_all_checks; then
        log "OK" "Health check passed. System stable."
        recovery_count=0
        update_status "Healthy"
        sleep "$CHECK_INTERVAL"
        continue
    fi

    if [ "$MONITOR_ONLY" == "yes" ]; then
        log "INFO" "Monitor mode enabled. Taking no recovery action. Sleeping..."
        update_status "Degraded (Monitor Only)"
        sleep "$CHECK_INTERVAL"
        continue
    fi
    
    # TRANSIENT CHECK
    update_status "Recovering (Phase 1)"
    log "INFO" "Waiting 30 seconds before re-testing (transient failure check)..."
    sleep 30
    if run_all_checks; then
        log "OK" "Transient failure resolved automatically."
        recovery_count=0
        update_status "Healthy"
        sleep "$CHECK_INTERVAL"
        continue
    fi

    # =========================================================
    # NEW LOGIC: DNS PRIORITY RECOVERY
    # =========================================================
    if ! check_dns; then
        log "CRITICAL" "Persistent DNS failure detected. Entering DNS-First Recovery Mode."
        update_status "Recovering (DNS Priority)"
        
        # 1. Kill VPN instantly to clear routing tables and stop interference
        log "INFO" "Stopping VPN services to restore raw ISP route..."
        systemctl stop "$OPENVPN_SERVICE" "$WIREGUARD_SERVICE" 2>/dev/null
        
        # 2. Loop indefinitely until DNS is back
        while ! check_dns; do
            log "WARN" "Restarting DNSCrypt-proxy..."
            systemctl restart "$DNSCRYPT_SERVICE"
            sleep 5
        done
        
        log "OK" "DNS successfully restored! Re-initiating VPN tunnel..."
        
        # 3. Boot VPN back up
        if [ "$VPN_TYPE" == "openvpn" ]; then
            systemctl start "$OPENVPN_SERVICE"
        else
            systemctl start "$WIREGUARD_SERVICE"
        fi
        
        if wait_for_tunnel; then sleep 2; else sleep 5; fi
        
        if run_all_checks; then
            log "INFO" "DNS-First recovery successful."
            recovery_count=0
            update_status "Healthy"
        else
            log "WARN" "DNS is up, but VPN failed to establish. Delegating to standard recovery on next cycle."
        fi
        
        sleep "$CHECK_INTERVAL"
        continue
    fi
    # =========================================================


    # STANDARD VPN RECOVERY (DNS is OK, but VPN failed)
    # Circuit Breaker Check
    if [ "$recovery_count" -ge "$MAX_RECOVERY_ATTEMPTS" ]; then
        log "CRITICAL" "Max recovery attempts ($MAX_RECOVERY_ATTEMPTS) reached."
        log "CRITICAL" "Entering cooldown mode. Next attempt in $COOLDOWN_PERIOD seconds."
        update_status "Cooldown (Max Attempts Reached)"
        sleep "$COOLDOWN_PERIOD"
        recovery_count=0 
        continue
    fi

    recovery_count=$((recovery_count + 1))
    log "INFO" "Recovery attempt: $recovery_count/$MAX_RECOVERY_ATTEMPTS."

    # RECOVERY PHASE 2: Restart VPN
    update_status "Recovering (Phase 2 - VPN Restart)"
    log "INFO" "Restarting $VPN_TYPE service..."
    if [ "$VPN_TYPE" == "openvpn" ]; then
        systemctl restart "$OPENVPN_SERVICE"
    else
        systemctl restart "$WIREGUARD_SERVICE"
    fi
    
    if wait_for_tunnel; then sleep 2; else sleep 5; fi
    
    if run_all_checks; then
        log "INFO" "VPN recovery successful."
        recovery_count=0
        update_status "Healthy"
        sleep "$CHECK_INTERVAL"
        continue
    fi

    # RECOVERY PHASE 3: Hard Restart
    update_status "Recovering (Phase 3 - Hard Restart)"
    log "WARN" "Performing hard restart of DNSCrypt and VPN..."
    systemctl restart "$DNSCRYPT_SERVICE"
    sleep 2
    if [ "$VPN_TYPE" == "openvpn" ]; then
        systemctl restart "$OPENVPN_SERVICE"
    else
        systemctl restart "$WIREGUARD_SERVICE"
    fi
    
    if wait_for_tunnel; then
        log "OK" "Tunnel $TUN_INTERFACE restored after hard recovery."
        sleep 2
    else
        log "WARN" "Tunnel $TUN_INTERFACE still missing after hard recovery."
    fi
    
    log "INFO" "Hard recovery cycle complete. Returning to sleep loop."
    sleep "$CHECK_INTERVAL"
done
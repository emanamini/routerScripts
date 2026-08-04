#!/usr/bin/env bash
# ==============================================================================
# Arch Router & Gateway Automated Backup (Rclone Cloud Sync Edition)
# ==============================================================================
# Exit on error, undefined variable, or pipeline failure
# set -Eeuo pipefail
# ==============================================================================
# Configuration
# ==============================================================================
BACKUP_DIR="/opt/router/BackupArchives"
STATE_DIR="/opt/router/BackupState"
LOG_FILE="$STATE_DIR/backup.log"
KEEP_BACKUPS=50
CONFIG_PATH="/root/.config/rclone/rclone.conf"
# Recommendation: Change this to an rclone crypt remote once configured
MEGA_DEST="RouterBackup:RouterBackup"
LOCK_FILE="/run/lock/router-backup.lock"
# Array of individual critical configuration files
FILES=(
    "/etc/fstab"
    "/etc/nftables.conf"
    "/etc/dnsmasq.conf"
    "/etc/iproute2/rt_tables"
    "/etc/wireguard/tun0.conf"
    "/etc/openvpn/client/tun0.conf"
    "/etc/udev/rules.d/10-network-names.rules"
    "/etc/resolv.conf"
    "/etc/passwd"
    "/etc/group"
    "/etc/shadow"
    "/etc/gshadow"
    "/etc/locale.conf"
    "/etc/vconsole.conf"
    "$STATE_DIR/packages-explicit.txt"
    "$STATE_DIR/packages-foreign.txt"
    "/etc/sudoers"
    "/etc/vpn-manager.conf"
)
# Array of critical directories (static ones)
DIRS=(
    "/opt/router/Scripts"
    "/root/.ssh"
    "/etc/ssh"
    "/etc/systemd/network"
    "/etc/systemd/system"
    "/etc/modprobe.d"
    "/etc/nftables.d"
    "/etc/dnscrypt-proxy"
    "/opt/arch-portal"
    "/etc/caddy"
    "/etc/sysctl.d"
)

# Dynamically add every user's ~/.ssh directory that exists
for home in /home/*; do
    if [[ -d "$home/.ssh" ]]; then
        DIRS+=("$home/.ssh")
    fi
done
# ==============================================================================
# Helper Functions
# ==============================================================================
log() {
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "$timestamp $1" | tee -a "$LOG_FILE"
}
trim_log() {
    if [[ -f "$LOG_FILE" ]]; then
        tail -n 1000 "$LOG_FILE" > "${LOG_FILE}.tmp" && mv "${LOG_FILE}.tmp" "$LOG_FILE"
    fi
}
check_deps() {
    local deps=("tar" "zstd" "rclone" "sha256sum" "flock" "find" "stat")
    for cmd in "${deps[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            log "ERROR: Required command '$cmd' is not installed."
            exit 1
        fi
    done
}
setup_dirs() {
    mkdir -p "$BACKUP_DIR" "$STATE_DIR"
    chmod 700 "$BACKUP_DIR" "$STATE_DIR"

    # Enforce strict permissions on root SSH keys before backup
    if [[ -d "/root/.ssh" ]]; then
        chmod 700 /root/.ssh
        find /root/.ssh -type f -exec chmod 600 {} + 2>/dev/null || true
    fi
}
calculate_hash() {
    # Calculates a unified SHA256 hash including BOTH contents and metadata (permissions/owners)
    local temp_file
    temp_file=$(mktemp)

    # Ensure temporary file is removed when the function exits
    trap 'rm -f "$temp_file"' RETURN
    for f in "${FILES[@]}"; do
        if [[ -f "$f" ]]; then
            # %a = octal permissions, %U = owner, %G = group, %n = name
            stat -c '%a %U %G %n' "$f" >> "$temp_file"
            sha256sum "$f" >> "$temp_file"
        fi
    done
    for d in "${DIRS[@]}"; do
        if [[ -d "$d" ]]; then
            # Suppress find errors in case temporary files disappear during execution
            find "$d" -type f -print0 2>/dev/null | while IFS= read -r -d '' f; do
                stat -c '%a %U %G %n' "$f" >> "$temp_file"
                sha256sum "$f" >> "$temp_file"
            done
        fi
    done
    sort -k 2 "$temp_file" | sha256sum | awk '{print $1}'
}
cleanup_old_backups() {
    local total_backups
    total_backups=$(ls -1 "$BACKUP_DIR"/router-*.tar.zst 2>/dev/null | wc -l || true)

    if (( total_backups > KEEP_BACKUPS )); then
        ls -tp "$BACKUP_DIR"/router-*.tar.zst | grep -v '/$' | tail -n +$((KEEP_BACKUPS + 1)) | xargs -d '\n' rm -f --
        log "Cleaned up old archives. Keeping the newest $KEEP_BACKUPS."
    fi
}
# ==============================================================================
# Main Execution Flow
# ==============================================================================
exec 9> "$LOCK_FILE"
if ! flock -n 9; then
    exit 0
fi
check_deps
setup_dirs
# Trap interruptions safely now that logging directories exist
trap 'log "ERROR: Backup interrupted by signal"; exit 1' INT TERM
# Generate dynamic system state (sorted to ensure stable hashes)
# || true prevents script failure if there are no AUR packages installed
if command -v pacman >/dev/null 2>&1; then
    pacman -Qqe | sort > "$STATE_DIR/packages-explicit.txt" || true
    pacman -Qqem | sort > "$STATE_DIR/packages-foreign.txt" || true
fi
CURRENT_HASH=$(calculate_hash)
HASH_FILE="$STATE_DIR/current.sha256"
if [[ -f "$HASH_FILE" ]] && [[ "$CURRENT_HASH" == "$(cat "$HASH_FILE")" ]]; then
    log "Checking configuration... No changes detected."
    trim_log
    exit 0
fi
log "Checking configuration... Changes detected."
EXISTING_PATHS=()
for p in "${FILES[@]}" "${DIRS[@]}"; do
    if [[ -e "$p" ]]; then
        EXISTING_PATHS+=("$p")
    else
        log "Warning: Path $p does not exist. Skipping."
    fi
done
if [[ ${#EXISTING_PATHS[@]} -eq 0 ]]; then
    log "ERROR: No target files or directories exist. Aborting."
    trim_log
    exit 1
fi
ARCHIVE_NAME="router-$(date +%Y-%m-%d_%H%M%S).tar.zst"
ARCHIVE_PATH="$BACKUP_DIR/$ARCHIVE_NAME"
MANIFEST="$STATE_DIR/manifest.txt"
cat <<EOF > "$MANIFEST"
Backup Date : $(date -u +"%Y-%m-%d %H:%M:%S UTC")
Hostname : $(cat /etc/hostname)
User : $USER
Kernel : $(uname -r)
Archive : $ARCHIVE_NAME
Included Paths:
$(printf "%s\n" "${EXISTING_PATHS[@]}")
EOF
# IMPORTANT: Archive contains absolute paths (-P). Restore only after reviewing contents.
tar --zstd -cpf "$ARCHIVE_PATH" -C "$STATE_DIR" manifest.txt -P "${EXISTING_PATHS[@]}"
sync
# Verify archive integrity
if ! tar --zstd -tf "$ARCHIVE_PATH" >/dev/null 2>&1; then
    log "CRITICAL ERROR: Archive verification failed. Corrupted backup deleted."
    rm -f "$ARCHIVE_PATH"
    trim_log
    exit 1
fi
# Update State and secure files
echo "$CURRENT_HASH" > "$HASH_FILE"
echo "$ARCHIVE_NAME" > "$STATE_DIR/last_backup"
chmod 600 "$HASH_FILE" "$MANIFEST" "$STATE_DIR/last_backup"
log "Created and verified archive: $ARCHIVE_NAME"
cleanup_old_backups
sleep 2
log "Syncing to MEGA..."
if rclone --config "$CONFIG_PATH" sync "$BACKUP_DIR" "$MEGA_DEST"; then
    log "rclone sync successful"
else
    log "ERROR: rclone sync failed"
    trim_log
    exit 1
fi
trim_log

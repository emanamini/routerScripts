#!/bin/bash
# Automatically triggered by systemd when the diag USB is inserted

DEVICE=$1
MOUNT_POINT="/mnt/diag_usb_temp"
YOUR_SCRIPT="/opt/router/Scripts/router-diagnostics.sh"

# 1. Create mount point and mount
mkdir -p "$MOUNT_POINT"
mount "$DEVICE" "$MOUNT_POINT"

# Check if mount was successful
if [ $? -eq 0 ]; then
    # 2. Run your comprehensive diagnostic script
    bash "$YOUR_SCRIPT" "$MOUNT_POINT"
    
    # 3. Ensure all data is written to the USB drive before unmounting
    sync
    
    # 4. Safely unmount so the user can pull the drive out
    umount "$MOUNT_POINT"
    
    # Clean up the temporary mount directory
    rmdir "$MOUNT_POINT"
fi

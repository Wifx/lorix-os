#!/bin/sh

PREFIX=MIGRATE-OPKG-STATUS-RESTORE
source /data/mender/upgrade/migration-env.sh

USER_OPKG_STATUS_FILE="/var/lib/opkg/status"
USER_OPKG_STATUS_BACKUP_FILE="$USER_OPKG_STATUS_FILE.bak"

# If backup file exists, restore it
if [ ! -f "$USER_OPKG_STATUS_BACKUP_FILE" ]; then
    log $PREFIX "No backup user opkg status file found, skipping restore"
    exit 0
fi

log $PREFIX "Restoring user opkg status file from backup"
mv -f "$USER_OPKG_STATUS_BACKUP_FILE" "$USER_OPKG_STATUS_FILE"
if [ $? -ne 0 ]; then
    log $PREFIX "Failed to restore user opkg status file from backup"
    exit 1
fi

log $PREFIX "User opkg status file restored successfully"
exit 0

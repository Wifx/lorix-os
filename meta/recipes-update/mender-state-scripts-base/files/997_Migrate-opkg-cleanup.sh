#!/bin/sh

PREFIX=MIGRATE-OPKG-CLEANUP
source /data/mender/upgrade/migration-env.sh

USER_OPKG_STATUS_FILE="/var/lib/opkg/status"
USER_OPKG_STATUS_BACKUP_FILE="$USER_OPKG_STATUS_FILE.bak"

# If backup file exists, delete it
if [ -f "$USER_OPKG_STATUS_BACKUP_FILE" ]; then
    log $PREFIX "Removing backup opkg status file"
    rm -f "$USER_OPKG_STATUS_BACKUP_FILE"
    exit 0
fi

#!/bin/sh

PREFIX=RESTORE-LOGS
source /data/mender/upgrade/migration-env.sh

UPGRADE_LOG_DIR=${UPGRADE_LOG_PATH%/*}

if [ -d "$UPGRADE_LOG_PERSISTENT_DIR" ]; then
    # Check if there are files in the directory before moving
    if [ "$(ls -A "$UPGRADE_LOG_PERSISTENT_DIR")" ]; then
        mkdir -p "$UPGRADE_LOG_DIR"
        mv $UPGRADE_LOG_PERSISTENT_DIR/* -t "$UPGRADE_LOG_DIR"
        log $PREFIX "Upgrade logs have been restored from persistent storage"
    else
        log $PREFIX "No logs to restore in $UPGRADE_LOG_PERSISTENT_DIR"
    fi
fi

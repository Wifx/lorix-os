#!/bin/sh

PREFIX=RESTORE-LOGS
source /data/mender/migration-env

if [ -d "$UPGRADE_LOG_PERSISTENT_DIR" ]; then
    log $PREFIX "Restoring upgrade logs"
    mv $UPGRADE_LOG_PERSISTENT_DIR/* "${UPGRADE_LOG_PATH%/*}"
fi

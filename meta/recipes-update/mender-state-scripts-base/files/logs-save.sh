#!/bin/sh

PREFIX=SAVE-LOGS
source /data/mender/migration-env

if [ -f "$UPGRADE_LOG_PATH" ]; then
    log $PREFIX "Saving '$UPGRADE_LOG_PATH' to '$UPGRADE_LOG_PERSISTENT_DIR'"
    mkdir -p $UPGRADE_LOG_PERSISTENT_DIR
    cp "$UPGRADE_LOG_PATH" $UPGRADE_LOG_PERSISTENT_DIR/
    log $PREFIX "Logs have been saved to '$UPGRADE_LOG_PERSISTENT_DIR'"
fi

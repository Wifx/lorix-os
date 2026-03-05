#!/bin/sh

PREFIX=SAVE-LOGS

if [[ ! -f /data/mender/upgrade/migration-env.sh ]]; then
    echo $PREFIX "migration-env.sh does not exist, skipping"
    exit 0
fi

source /data/mender/upgrade/migration-env.sh

if [ -f "$UPGRADE_LOG_PATH" ]; then
    log $PREFIX "Saving '$UPGRADE_LOG_PATH' to '$UPGRADE_LOG_PERSISTENT_DIR'"
    mkdir -p $UPGRADE_LOG_PERSISTENT_DIR
    cp "$UPGRADE_LOG_PATH" $UPGRADE_LOG_PERSISTENT_DIR/
    log $PREFIX "Logs have been saved to '$UPGRADE_LOG_PERSISTENT_DIR'"
fi

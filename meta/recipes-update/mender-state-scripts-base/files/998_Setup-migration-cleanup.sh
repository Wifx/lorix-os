#!/bin/sh

PREFIX=MIGRATION-CLEANUP

if [[ ! -f /data/mender/upgrade/migration-env.sh ]]; then
    log $PREFIX "migration-env.sh does not exist, probably performing rollback"
    exit 0
fi

source /data/mender/upgrade/migration-env.sh

# Unmount writable inactive user config

if [ -d "$LAYER_USER_CONFIG_INACTIVE_RW" ]; then
    log $PREFIX "Unmounting inactive user configuration"
    umount $LAYER_USER_CONFIG_INACTIVE_RW
    rmdir $LAYER_USER_CONFIG_INACTIVE_RW
fi

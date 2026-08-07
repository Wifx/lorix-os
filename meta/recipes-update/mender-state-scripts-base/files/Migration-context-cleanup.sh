#!/bin/sh

PREFIX=MIGRATION-CLEANUP

if [[ ! -f /data/mender/upgrade/migration-env.sh ]]; then
    echo $PREFIX "migration-env.sh does not exist, skipping"
    exit 0
fi

source /data/mender/upgrade/migration-env.sh

# Unmount writable inactive user config

if [ -d "$LAYER_USER_CONFIG_INACTIVE_RW" ]; then
    log $PREFIX "Unmounting inactive user configuration"
    umount $LAYER_USER_CONFIG_INACTIVE_RW
    rmdir $LAYER_USER_CONFIG_INACTIVE_RW
fi

# Unmount inactive factory layer
if [ -d "$LAYER_FACTORY_INACTIVE" ]; then
    log $PREFIX "Unmounting inactive factory layer"
    umount $LAYER_FACTORY_INACTIVE
    rmdir $LAYER_FACTORY_INACTIVE
fi

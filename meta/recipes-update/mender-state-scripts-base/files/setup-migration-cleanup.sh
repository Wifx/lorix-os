#!/bin/sh

PREFIX=MIGRATION-CLEANUP
source /data/mender/migration-env

# Unmount writable inactive user config

if [ -d "$LAYER_USER_CONFIG_INACTIVE_RW" ]; then
    log $PREFIX "Unmounting inactive user configuration"
    umount $LAYER_USER_CONFIG_INACTIVE_RW
    rmdir $LAYER_USER_CONFIG_INACTIVE_RW
fi

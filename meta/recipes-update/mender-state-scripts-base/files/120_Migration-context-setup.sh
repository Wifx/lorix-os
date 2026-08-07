#!/bin/sh

PREFIX=MIGRATION

source /data/mender/upgrade/migration-env.sh

# Mount writable inactive user config

log $PREFIX "Preparing inactive user configuration mount point: '$LAYER_USER_CONFIG_INACTIVE_RW'"
mkdir -p "$LAYER_USER_CONFIG_INACTIVE_RW"

log $PREFIX "Mounting inactive user configuration as read/write"
mount --bind $LAYER_USER_CONFIG_INACTIVE $LAYER_USER_CONFIG_INACTIVE_RW
mount -o remount,rw -t ubifs $LAYER_USER_CONFIG_INACTIVE_RW
log $PREFIX "Inactive user configuration mounted on '$LAYER_USER_CONFIG_INACTIVE_RW'"

log $PREFIX "Cleanup inactive user config layer"
rm -rf $LAYER_USER_CONFIG_INACTIVE_RW/*

# Mount inactive factory layer
mkdir -p "$LAYER_FACTORY_INACTIVE"
log $PREFIX "Mounting inactive factory layer ($LAYER_FACTORY_INACTIVE_UBI)"
mount -t ubifs $LAYER_FACTORY_INACTIVE_UBI $LAYER_FACTORY_INACTIVE
log $PREFIX "Inactive factory layer mounted on '$LAYER_FACTORY_INACTIVE'"

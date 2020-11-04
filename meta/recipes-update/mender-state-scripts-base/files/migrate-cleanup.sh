#!/bin/sh

PREFIX=CLEANUP
source /data/mender/migration-env

# Mount writable inactive user config
mkdir -p "$LAYER_USER_CONFIG_INACTIVE_RW"
    
log $PREFIX "Mounting inactive user configuration as read/write on '$LAYER_USER_CONFIG_INACTIVE_RW'"
mount --bind $LAYER_USER_CONFIG_INACTIVE $LAYER_USER_CONFIG_INACTIVE_RW
mount -o remount,rw -t ubifs $LAYER_USER_CONFIG_INACTIVE_RW

log $PREFIX "Cleaning old user config to free space"
rm -rf $LAYER_USER_CONFIG_INACTIVE_RW/*

log $PREFIX "Unmounting inactive user configuration"
umount "$LAYER_USER_CONFIG_INACTIVE_RW"

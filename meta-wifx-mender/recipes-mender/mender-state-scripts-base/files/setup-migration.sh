#!/bin/sh

PREFIX=MIGRATION
source /data/mender/migration-env

# Mount writable inactive user config

mkdir -p "$LAYER_USER_CONFIG_INACTIVE_RW"

log $PREFIX "Mounting inactive user configuration as read/write"
mount --bind $LAYER_USER_CONFIG_INACTIVE $LAYER_USER_CONFIG_INACTIVE_RW
mount -o remount,rw -t ubifs $LAYER_USER_CONFIG_INACTIVE_RW

log $PREFIX "Cleanup inactive user config layer"
rm -rf $LAYER_USER_CONFIG_INACTIVE_RW/*

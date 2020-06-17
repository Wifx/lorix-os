#!/bin/sh

PREFIX=CHECK-SPACE
source /data/mender/migration-env

USER_CONFIG_PATH="/etc"

log $PREFIX "Checking availalbe space for user config migration ($USER_CONFIG_PATH)"

DU=$(du -s $USER_CONFIG_PATH)
if [ "$?" -ne 0 ]; then
    log $PREFIX "Could not check user config size: $DU"
    exit 0
fi

CONFIG_SIZE=$(echo "$DU" | awk '{print $1}')
if [ "$?" -ne 0 ]; then
    log $PREFIX "Could not check user config size"
    exit 0
fi

DF=$(df $USER_CONFIG_PATH)
if [ "$?" -ne 0 ]; then
    log $PREFIX "Could not check available space: $DF"
    exit 0
fi

AVAILABLE=$(echo "$DF" | awk 'END {print $4}')
if [ "$?" -ne 0 ]; then
    log $PREFIX "Could not check available space"
    exit 0
fi

log $PREFIX "- User config size: $CONFIG_SIZE kB"
log $PREFIX "- Available space: $AVAILABLE kB"

if [ "$AVAILABLE" -gt "$CONFIG_SIZE" ]; then
    log $PREFIX "Enough space for user configuration migration"
    exit 0
else
    log $PREFIX "Not enough space for user configuration migration"
    log $PREFIX "You need at least the size of the user config as available space"
    exit 1
fi


#!/bin/sh

PREFIX=CFG_MIG_ON
source /data/mender/migration-env

# Disable migration only for the 0.4.0 version
if [[ "$ORIGIN_VERSION" == "0.4.0-rc.1" || "$ORIGIN_VERSION" == "0.4.0-rc.2" ]]; then

    LAYER_USER_CONFIG_INACTIVE_BK=${LAYER_USER_CONFIG_INACTIVE}-bk
    INHIBITED_MOUNT_POINT=/var/tmp/migration

    if [ ! -d "$LAYER_USER_CONFIG_INACTIVE_BK" ]; then
        log $PREFIX "WARN - Inactive configuration backup mount point '$LAYER_USER_CONFIG_INACTIVE_BK' does not exist"
        
        if [ ! -d "$LAYER_USER_CONFIG_INACTIVE" ]; then
            log $PREFIX "INFO - Already resotred to '$LAYER_USER_CONFIG_INACTIVE'"
            exit 0
        else
            log $PREFIX "ERROR - could not find original moint point '$LAYER_USER_CONFIG_INACTIVE' either"
        fi

        exit 0 # Should fail ?
    fi

    log $PREFIX "Remove inhibited mount point at '$LAYER_USER_CONFIG_INACTIVE'"
    umount $LAYER_USER_CONFIG_INACTIVE

    log $PREFIX "Remove inhibited config storage at '$INHIBITED_MOUNT_POINT'"
    rm -rf $INHIBITED_MOUNT_POINT

    log $PREFIX "Restoring inactive configuration mount point from '$LAYER_USER_CONFIG_INACTIVE_BK' to '$LAYER_USER_CONFIG_INACTIVE'"
    mount --move $LAYER_USER_CONFIG_INACTIVE_BK $LAYER_USER_CONFIG_INACTIVE
    rm -rf $LAYER_USER_CONFIG_INACTIVE_BK

fi

#!/bin/sh

PREFIX=CFG_MIG_OFF
source /data/mender/migration-env

# Disable migration only fo the 0.4.0 version
if [[ "$ORIGIN_VERSION" == "0.4.0-rc.1" || "$ORIGIN_VERSION" == "0.4.0-rc.2" ]]; then
    
    LAYER_USER_CONFIG_INACTIVE_BK=${LAYER_USER_CONFIG_INACTIVE}-bk
    INHIBITED_MOUNT_POINT=/var/tmp/migration

    if [ ! -d "$LAYER_USER_CONFIG_INACTIVE" ]; then
        log $PREFIX "WARN - Inactive configuration mount point '$LAYER_USER_CONFIG_INACTIVE' does not exist"
        
        if [ ! -d "$LAYER_USER_CONFIG_INACTIVE_BK" ]; then
            log $PREFIX "INFO - Already moved to '$LAYER_USER_CONFIG_INACTIVE_BK'"
            exit 0
        else
            log $PREFIX "ERROR - could not find backup moint point '$LAYER_USER_CONFIG_INACTIVE_BK' either"
        fi

        exit 0 # Should fail ?
    fi

    log $PREFIX "Moving inactive configuration mount point from '$LAYER_USER_CONFIG_INACTIVE' to '$LAYER_USER_CONFIG_INACTIVE_BK'"

    mkdir -p $LAYER_USER_CONFIG_INACTIVE_BK
    mount --move $LAYER_USER_CONFIG_INACTIVE $LAYER_USER_CONFIG_INACTIVE_BK

    log $PREFIX "Creating inhibited mount point on '$LAYER_USER_CONFIG_INACTIVE'"

    mkdir -p $INHIBITED_MOUNT_POINT
    mount --bind $INHIBITED_MOUNT_POINT $LAYER_USER_CONFIG_INACTIVE

fi

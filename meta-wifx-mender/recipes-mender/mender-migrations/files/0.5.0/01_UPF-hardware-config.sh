#!/bin/sh

PREFIX=WPF-HW-CFG
source /data/mender/migration-env

VERSION_MAX="0.5.0"
source /data/mender/migration-utils

HARDWARE_DIR_PATH="$D_ETC/opt/wpf/hardware"
ABSOLUTE_HARDWARE_DIR_PATH="/etc/opt/wpf/hardware"

if [ -L "$HARDWARE_DIR_PATH/hardware_conf.json" ]; then

    log $PREFIX "Migrating UDP Packet Forwarder hardware configuration"

    HARDWARE_CONF_PATH=$(ls $HARDWARE_DIR_PATH/hardware_conf.json -l | awk '{print $11}')

    if [[ $HARDWARE_CONF_PATH =~ "2dBi" || $HARDWARE_CONF_PATH =~ "indoor" ]]; then
        GAIN="4dBi"
    elif [[ $HARDWARE_CONF_PATH =~ "4dBi" || $HARDWARE_CONF_PATH =~ "outdoor" ]]; then
        GAIN="4dBi"
    fi

    if [[ $HARDWARE_CONF_PATH =~ "EU868" ]]; then
        REGION="863-870"
    elif [[ $HARDWARE_CONF_PATH =~ "US915" || $HARDWARE_CONF_PATH =~ "AU915" ]]; then
        REGION="902-928"
    fi

    log $PREFIX "Detected configuration:"
    log $PREFIX "- Region: $REGION"
    log $PREFIX "- Gain: $GAIN"

    if [[ -z "$REGION" || -z "$GAIN" ]]; then
        log $PREFIX "Could not detect gain or region, file probably already migrated"
        log $PREFIX "- Region: $REGION"
        log $PREFIX "- Gain: $GAIN"
        log $PREFIX "- Conf path : '$HARDWARE_CONF_PATH'"
        exit 0
    fi

    ln -sf ${ABSOLUTE_HARDWARE_DIR_PATH}/$REGION/hardware_conf_$GAIN.json ${HARDWARE_DIR_PATH}/hardware_conf.json
    ln -sf ${ABSOLUTE_HARDWARE_DIR_PATH}/$REGION/hardware_conf_$GAIN.json.sha256 ${HARDWARE_DIR_PATH}/hardware_conf.json.sha256

    log $PREFIX "UDP Packet Forwarder hardware config migration done"
fi

exit 0

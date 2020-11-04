#!/bin/sh

PREFIX=UPF-FROM-WPF
source /data/mender/migration-env

VERSION_MAX="0.6.1"
source /data/mender/migration-utils

WPF_DIR_PATH="opt/wpf"
UPF_DIR_PATH="opt/udp-packet-forwarder"

cd $D_ETC

if [[ -d "$WPF_DIR_PATH" ]]; then
    log $PREFIX "Migrating WPF Packet Forwarder config files to UDP Packet Forwarder folders"

    mkdir -p $UPF_DIR_PATH
    cp -af $WPF_DIR_PATH/* $UPF_DIR_PATH # We use cp/rm instead of mv to keep existing files
    rm -rf $WPF_DIR_PATH

    log $PREFIX "Updating WPF Packet Forwarder config files symbolinc links"

    for symlink in $(find $UPF_DIR_PATH -type l); do
        newSymlink=${symlink//$WPF_DIR_PATH/$UPF_DIR_PATH}
        target=$(ls $symlink -l | awk '{print $11}')
        newTarget=${target//$WPF_DIR_PATH/$UPF_DIR_PATH}
        ln -sf $newTarget $symlink
    done

    log $PREFIX "WPF config migration done"
else
    log $PREFIX "'$WPF_DIR_PATH' not found, skipping migration"
fi

WPF_PMON_CFG="pmonitor/services-enabled/wifx-packet-forwarder-generic.yml"
if [[ -L $WPF_PMON_CFG ]]; then
    log $PREFIX "Migrating pmonitor WPF config '$WPF_PMON_CFG'"
    rm -f $WPF_PMON_CFG
    ln -sf  "/etc/pmonitor/services-available/udp-packet-forwarder-generic.yml" "pmonitor/services-enabled/udp-packet-forwarder-generic.yml"
else
    log $PREFIX "pmonitor WPF config not found, skipping migration"
fi

exit 0

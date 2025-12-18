#!/bin/sh

PREFIX=OPKG-CFG
source /data/mender/upgrade/migration-env.sh
    
log $PREFIX "Configuring OPKG packages..."

# Run opkg configure of all packages, except mender and mender-auth
opkg list-installed | grep 'unpacked' | awk '{print $1}' | grep -v -x 'mender' | grep -v -x 'mender-auth' | xargs -r opkg configure

if [ "$?" -ne 0 ]; then
    log $PREFIX "Could not configure OPKG packages. Please run 'opkg configure' manually"
else
    log $PREFIX "OPKG packages configured"
fi

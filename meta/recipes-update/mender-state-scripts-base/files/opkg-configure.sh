#!/bin/sh

PREFIX=OPKG-CFG
source /data/mender/migration-env
    
log $PREFIX "Configuring OPKG packages..."

opkg configure

if [ "$?" -ne 0 ]; then
    log $PREFIX "Could not configure OPKG packages. Please run 'opkg configure' manually"
else
    log $PREFIX "OPKG packages configured"
fi

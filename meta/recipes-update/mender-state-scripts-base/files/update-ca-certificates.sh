#!/bin/sh

PREFIX=CA-CERT
source /data/mender/migration-env
    
log $PREFIX "Updating CA certificates store..."

update-ca-certificates --verbose

if [ "$?" -ne 0 ]; then
    log $PREFIX "Could not update CA store. Please run 'update-ca-certificates' manually"
else
    log $PREFIX "CA store updated"
fi

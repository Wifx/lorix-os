#!/bin/sh

if [[ ! -f /data/mender/upgrade/migration-env.sh ]]; then
    log $PREFIX "migration-env.sh does not exist, probably performing rollback"
    exit 0
fi

source /data/mender/upgrade/migration-env.sh

PREFIX=FINAL-CLEANUP

log $PREFIX "Cleaning up"
rm -rf $MENDER_UPGRADE_DIR

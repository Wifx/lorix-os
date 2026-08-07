#!/bin/sh

if [[ ! -f /data/mender/upgrade/migration-env.sh ]]; then
    >&2 echo "$(date +"%Y-%m-%dT%H:%m:%SZ") [$PREFIX] migration-env.sh does not exist, skipping"
    exit 0
fi

source /data/mender/upgrade/migration-env.sh

PREFIX=FINAL-CLEANUP

log $PREFIX "Cleaning up"
rm -rf $MENDER_UPGRADE_DIR

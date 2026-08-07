#!/bin/sh

PREFIX=MIGRATE
source /data/mender/upgrade/migration-env.sh

log $PREFIX "Migrating '$S_ETC' to '$D_ETC'"
cp -a $S_ETC/* $D_ETC
RESULT=$?

if [[ $RESULT -eq 0 ]]; then
    log $PREFIX "Migration successful"
    exit 0
else
    log $PREFIX "Migration failed"
    exit 1
fi

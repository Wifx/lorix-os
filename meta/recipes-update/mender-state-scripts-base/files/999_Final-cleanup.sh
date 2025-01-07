#!/bin/sh

source /data/mender/upgrade/migration-env.sh

PREFIX=FINAL-CLEANUP

log $PREFIX "Cleaning up"
rm -rf $MENDER_UPGRADE_DIR

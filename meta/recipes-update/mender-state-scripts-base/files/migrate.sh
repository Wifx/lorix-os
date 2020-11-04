#!/bin/sh

PREFIX=MIGRATE
source /data/mender/migration-env

cp -a $S_ETC/* $D_ETC
RESULT=$?

if [[ $RESULT -eq 0 ]]; then
    log $PREFIX "The migration was successfull"
    exit 0
else
    log $PREFIX "The migration was not successfull"
    exit 1
fi

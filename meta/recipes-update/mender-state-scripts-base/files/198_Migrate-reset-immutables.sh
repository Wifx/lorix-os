#!/bin/sh

PREFIX=MIGRATE-RESET-IMMUTABLES
source /data/mender/upgrade/migration-env.sh

# Some files must not be migrated if the user has changed them
ETC_FILES=( 
    os-release
    ca-certificates.conf
)
for FILE in "${ETC_FILES[@]}"
do
	FILE_PATH=$D_ETC/$FILE
    if [[ -f "$FILE_PATH" || -L "$FILE_PATH" ]]; then
        log $PREFIX "File /etc/$FILE has been modified, restoring factory file"
        rm $FILE_PATH
    else
        log $PREFIX "File /etc/$FILE has not been modified"
    fi
done


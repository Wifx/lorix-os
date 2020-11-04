#!/bin/sh

PREFIX=MIGRATE-RESET-IMMUTABLES
source /data/mender/migration-env

# Some files must not be migrated if the user has changed them
ETC_FILES=( 
    os-release
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


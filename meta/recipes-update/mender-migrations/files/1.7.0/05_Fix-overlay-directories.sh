#!/bin/sh

# NOTES
# This migration recreates the overlay directories in the user overlay diff.
# This has to be done as it seems that the directories created in the overlay 
# with overlayfs of version <1.6 are not compatible with the overlayfs of version >=1.7,
# thus showing only the content of the upper layer instead of a merge of lower and upper dir.
# Creating the directories directely in the diff (instead of on top of the overlay) works.

### CONFIGURE THE MIGRATION ###

# The prefix will be shown in the logs only. Keep it short. E.g. "NM-PROF-MV"
PREFIX=FIX-OVERLAY-DIRS 

# The following versions description uses semver: https://semver.org/
# Condition syntax is defined by semver_rs "Range" object: https://docs.rs/semver_rs/0.1.3/semver_rs/struct.Range.html.

# Defines what is the lowest version (included) of the source system for the migration to be applied (semver).
# You should set this if an old version does not have the software/files you try to migrate.
# WARNING: rember that a beta/rc is older (<) than a release
# Must not be empty. Can be left undefined.
# VERSION_MIN="0.6.0" 

# Defines what is the highest version (excluded) of the source system for the migration to be applied (semver).
# This is generally set to the current version. If the user has this version (or higher), the migration is already done and not useful anymore.
# Must not be empty. Can be left undefined.
VERSION_MAX="1.7.0" 

# Condition that will be finally be checked to know if the migration will be applied.
# Is automatically generated with VERSION_MIN and VERSION_MAX if not defined. If defined VERSION_MIN/MAX are ignored
#MIGRATION_CONDITION=">=0.4.0 <0.6.1" 

### DO NO CHANGE THE FOLLOWING TWO LINES ###

# Load the work variables (do not change)
# - $S_ETC : active etc diff, readonly (/var/lib/os/layers/active/config)
# - $D_ETC : inactive etc diff, readwrite (/var/lib/os/layers/inactive/config mounted on /var/lib/migration/config)
# - $S_ROOT : factory root of the active partition, readonly (/var/lib/os/layers/active/factory)
source /data/mender/upgrade/migration-env.sh 

# Checks wheteher the migration should be applied or not (do not change)
source /data/mender/upgrade/version-guard.sh

### WRITE YOUR MIGRATION FROM HERE ###

UBIDATA_MOUNT_PATH=/var/lib/migration/ubidata

function restore() {
    DIR=$1
    DIR_BK="$DIR.migration-backup"

    if [ -d "$DIR_BK" ]; then
        mv $DIR/* $DIR_BK
        rm -rf $DIR
        mv "$DIR_BK" "$DIR"
    fi
}


# Mount ubidata volume
log $PREFIX "Mounting ubidata volume on $UBIDATA_MOUNT_PATH"

mkdir -p $UBIDATA_MOUNT_PATH
if [ $? -ne 0 ]; then
    log $PREFIX "Failed to create directory $UBIDATA_MOUNT_PATH"
    exit 1
fi

mount -t ubifs ubi0:data $UBIDATA_MOUNT_PATH
if [ $? -ne 0 ]; then
    log $PREFIX "Failed to mount ubidata volume on $UBIDATA_MOUNT_PATH"
    rm -rf $UBIDATA_MOUNT_PATH
    exit 1
fi

USER_OVERLAY_DIFF_PATH="$UBIDATA_MOUNT_PATH/overlay/user/diff"

log $PREFIX "Migrating..."

DIRECTORIES=( 
    "$USER_OVERLAY_DIFF_PATH/var/lib/os"
)
for DIR in "${DIRECTORIES[@]}"
do

    DIR_BK="$DIR.migration-backup"

    # If directory does not exist, skip migration
    if [ ! -d $DIR ]; then
        log $PREFIX "$DIR does not exist, skipping"
        continue
    fi

    # Backup the original directory
    mv "$DIR" "$DIR_BK"
    if [ $? -ne 0 ]; then
        log $PREFIX "Failed to backup $DIR to $DIR_BK"
        restore $DIR
        break
    fi

    # Create the new directory
    mkdir -p "$DIR"
    if [ $? -ne 0 ]; then
        log $PREFIX "Failed to create directory $DIR"
        restore $DIR
        break
    fi

    # Move files from the backup to the new directory
    if [ "$(ls -A $DIR_BK)" ]; then
        mv $DIR_BK/* $DIR
        if [ $? -ne 0 ]; then
            log $PREFIX "Failed to move files from $DIR_BK to $DIR"
            restore $DIR
            break
        fi
    fi
    
    # Remove the backup directory
    rm -rf "$DIR_BK"
    if [ $? -ne 0 ]; then
        log $PREFIX "Failed to remove directory $DIR_BK"
        continue
    fi
done

# Cleanup
umount $UBIDATA_MOUNT_PATH
rm -rf $UBIDATA_MOUNT_PATH

log $PREFIX "Migration done"

exit 0

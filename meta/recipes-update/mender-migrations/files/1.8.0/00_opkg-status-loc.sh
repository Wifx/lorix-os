#!/bin/sh -e

### CONFIGURE THE MIGRATION ###

# The prefix will be shown in the logs only. Keep it short. E.g. "NM-PROF-MV"
PREFIX=OPKG-STATUS-LOC 

# The following versions description uses semver: https://semver.org/
# Condition syntax is defined by semver_rs "Range" object: https://docs.rs/semver_rs/0.1.3/semver_rs/struct.Range.html.

# Defines what is the lowest version (included) of the source system for the migration to be applied (semver).
# You should set this if an old version does not have the software/files you try to migrate.
# WARNING: remember that a beta/rc is older (<) than a release
# Must not be empty. Can be left undefined.
# VERSION_MIN="0.6.0" 

# Defines what is the highest version (excluded) of the source system for the migration to be applied (semver).
# This is generally set to the current version. If the user has this version (or higher), the migration is already done and not useful anymore.
# Must not be empty. Can be left undefined.
VERSION_MAX="1.8.0"

# Condition that will be finally be checked to know if the migration will be applied.
# Is automatically generated with VERSION_MIN and VERSION_MAX if not defined. If defined VERSION_MIN/MAX are ignored
#MIGRATION_CONDITION=">=0.4.0 <0.6.1" 

### DO NO CHANGE THE FOLLOWING TWO LINES ###

# Load the work variables (do not change)
# - $S_ETC : active etc diff, readonly (/var/lib/os/layers/active/config)
# - $D_ETC : inactive etc diff, readwrite (/var/lib/os/layers/inactive/config mounted on /var/lib/migration/config)
# - $S_ROOT : factory root of the active partition, readonly (/var/lib/os/layers/active/factory)
source /data/mender/upgrade/migration-env.sh 

# Checks whether the migration should be applied or not (do not change)
source /data/mender/upgrade/version-guard.sh

### WRITE YOUR MIGRATION FROM HERE ###

# You may generally want to go into /etc of the destination rootfs. 
# WARNING - Path to files MUST not contain /etc (would refer to the currently mounted config)
cd $S_ETC

OPKG_STATUS_PATH_OLD="/var/lib/opkg/status" 
OPKG_STATUS_PATH_NEW="slotfs/var/lib/opkg/status"

# Check if file does not exist or is a symlink (migration already done)
if [[ ! -f "$OPKG_STATUS_PATH_OLD" ]] || [[ -L "$OPKG_STATUS_PATH_OLD" ]]; then
    log $PREFIX "No opkg status to migrate"
    exit 0
fi

log $PREFIX "Migrating..."

# The migration steps will depend on the type of migration. Prefer post-migration.
# - Pre-migration : copy files from $S_ETC to $D_ETC, edit them but not rename them
# - Post-migration : add, edit or remove files in $D_ETC

# Migrate the current system too in case revert does not happen
mkdir -p "$(dirname "$OPKG_STATUS_PATH_NEW")"
mv -f "$OPKG_STATUS_PATH_OLD" "$OPKG_STATUS_PATH_NEW"
if [ $? -ne 0 ]; then
    log $PREFIX "Failed to move opkg status file to new location"
    exit 1
fi

# Create symlink from old location to new location
ln -s "/etc/$OPKG_STATUS_PATH_NEW" "$OPKG_STATUS_PATH_OLD"
if [ $? -ne 0 ]; then
    log $PREFIX "Failed to create symlink for opkg status file"
    exit 1
fi

log $PREFIX "Migration done"

exit 0

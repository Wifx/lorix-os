#!/bin/sh -e

### CONFIGURE THE MIGRATION ###

# The prefix will be shown in the logs only. Keep it short. E.g. "NM-PROF-MV"
PREFIX=MENDER-SERVICE-NAME

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

OPENRC_INIT_DIR="init.d"
OPENRC_CONF_DIR="conf.d"
OPENRC_RUNLEVELS_DIR="runlevels"

# You may generally want to go into /etc of the destination rootfs. 
# WARNING - Path to files MUST not contain /etc (would refer to the currently mounted config)
cd $D_ETC

if [ -d "$OPENRC_INIT_DIR" ]; then
    # Find all menderd init scripts and rename them to mender-update
    find "$OPENRC_INIT_DIR/" -type f -name "menderd" | while read -r filepath; do
        mv "$filepath" "${filepath%menderd}mender-update"
        log $PREFIX "Renamed $OPENRC_INIT_DIR/menderd to $OPENRC_INIT_DIR/mender-update"
    done
fi

if [ -d "$OPENRC_CONF_DIR" ]; then
    # Find all menderd conf scripts and rename them to mender-update
    find "$OPENRC_CONF_DIR/" -type f -name "menderd" | while read -r filepath; do
        mv "$filepath" "${filepath%menderd}mender-update"
        log $PREFIX "Renamed $OPENRC_CONF_DIR/menderd to $OPENRC_CONF_DIR/mender-update"
    done
fi

if [ -d "$OPENRC_RUNLEVELS_DIR" ]; then
    # Find all runlevels symlinks called menderd, rename them and update them to mender-update
    find "$OPENRC_RUNLEVELS_DIR/" -type l -name "menderd" | while read -r filepath; do
        dirname=$(dirname "$filepath")
        rm "$filepath"
        ln -s "/etc/$OPENRC_INIT_DIR/mender-update" "$dirname/mender-update"
        log $PREFIX "Updated runlevel symlink $filepath to point to mender-update"
    done
fi

log $PREFIX "Migration done"

exit 0

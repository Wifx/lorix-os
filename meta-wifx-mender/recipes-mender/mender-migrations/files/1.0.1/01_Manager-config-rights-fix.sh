#!/bin/sh

### CONFIGURE THE MIGRATION ###

# The prefix will be shown in the logs only. Keep it short. E.g. "NM-PROF-MV"
PREFIX=MANAGER-CFG-CHMOD 

# The following versions description uses semver: https://semver.org/
# Condition syntax is defined by semver_rs "Range" object: https://docs.rs/semver_rs/0.1.3/semver_rs/struct.Range.html.

# Condition that will be finally be checked to know if the migration will be applied.
# Is automatically generated with VERSION_MIN and VERSION_MAX if not defined. If defined VERSION_MIN/MAX are ignored
MIGRATION_CONDITION="=1.0.0" 

### DO NO CHANGE THE FOLLOWING TWO LINES ###

# Load the work variables (do not change)
# - $S_ETC : current etc diff, readonly (/data/layers/config/rootfs[A|B])
# - $D_ETC : current etc diff, readwrite (/data/layers/config/rootfs[A|B] mounted on /var/lib/manager/migration)
# - $S_ROOT : factory root of the active partition, readonly (/data/layers/factory)
source /data/mender/migration-env 

# Checks wheteher the migration should be applied or not (do not change)
source /data/mender/migration-utils 

### WRITE YOUR MIGRATION FROM HERE ###

# You may generally want to go into /etc of the destination rootfs. 
# WARNING - Path to files MUST not contain /etc (would refer to the currently mounted config)
cd $D_ETC

DEFAULT_CFG_DIR="manager/conf.d/00-default"

# It is generally a good thing to check wheter the migration should be applied or not depending on the FS state
if [[ ! -d "$DEFAULT_CFG_DIR" ]]; then
    log $PREFIX "No config dir to fix"
    exit 0
fi

log $PREFIX "Migrating..."

chmod 755 "$DEFAULT_CFG_DIR"

log $PREFIX "Migration done"

exit 0

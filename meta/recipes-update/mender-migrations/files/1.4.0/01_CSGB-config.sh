#!/bin/sh

### CONFIGURE THE MIGRATION ###

# The prefix will be shown in the logs only. Keep it short. E.g. "NM-PROF-MV"
PREFIX=CSGB-CFG

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
VERSION_MAX="1.4.0" 

# Condition that will be finally be checked to know if the migration will be applied.
# Is automatically generated with VERSION_MIN and VERSION_MAX if not defined. If defined VERSION_MIN/MAX are ignored
#MIGRATION_CONDITION=">=0.4.0 <0.6.1" 

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

CSGB_SRC_CONFIG="opt/chirpstack-gateway-bridge/chirpstack-gateway-bridge.toml" 
CSGB_INTEGRATION_CONFIG="opt/chirpstack-gateway-bridge/30-integration.toml" 

# Check if file exists
if [[ -f "$CSGB_SRC_CONFIG" ]]; then
    log $PREFIX "Migrating CSGB config..."

    echo "# See https://www.chirpstack.io/gateway-bridge/install/config/ for a full
# configuration example and documentation.

" > "$CSGB_INTEGRATION_CONFIG"

    sed -rz 's|.*(# Integration configuration.*)|\1|' "$CSGB_SRC_CONFIG" >> "$CSGB_INTEGRATION_CONFIG"

    echo "
" >> "$CSGB_INTEGRATION_CONFIG"

    mv "$CSGB_SRC_CONFIG" "$CSGB_SRC_CONFIG.bk"

else
    log $PREFIX "No CSGB config to migrate"
fi


PMON_CONFIG="pmonitor/services-available/chirpstack-gateway-bridge-udp.yml" 

if [[ -f "$PMON_CONFIG" ]]; then
    log $PREFIX "Migrating pmonitor CSGB service profile..."
    log $PREFIX "Restoring factory service profile..."
    rm "$PMON_CONFIG"
else
    log $PREFIX "No pmonitor CSGB service profile to migrate"
fi

# The migration steps will depend on the type of migration. Prefer post-migration.
# - Pre-migration : copy files from $S_ETC to $D_ETC, edit them but not rename them
# - Post-migration : add, edit or remove files in $D_ETC



log $PREFIX "Migration done"

exit 0

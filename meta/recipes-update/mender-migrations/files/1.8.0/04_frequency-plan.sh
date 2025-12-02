#!/bin/sh -e

### CONFIGURE THE MIGRATION ###

# The prefix will be shown in the logs only. Keep it short. E.g. "NM-PROF-MV"
PREFIX=CSCD-FP 

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
cd $D_ETC

CHANNEL_CONFIG_PATH="opt/chirpstack-concentratord/channels/channels.toml" # Refers to a file at /etc/someapp/config.yml

# It is generally a good thing to check wheter the migration should be applied or not depending on the FS state
if [[ ! -f "$CHANNEL_CONFIG_PATH" ]]; then
    log $PREFIX "No config to migrate"
    exit 0
fi

log $PREFIX "Migrating..."

# The migration steps will depend on the type of migration. Prefer post-migration.
# - Pre-migration : copy files from $S_ETC to $D_ETC, edit them but not rename them
# - Post-migration : add, edit or remove files in $D_ETC

# Read symlink target if any
CHANNEL_CONFIG_REAL_PATH=$(readlink -f "$CHANNEL_CONFIG_PATH")

# Update AS923/AS_923_925.toml to AS923/AS_923_1.toml
if grep -q "AS_923_925" "$CHANNEL_CONFIG_REAL_PATH"; then
    log $PREFIX "Updating AS923_925 to AS923_1 in $CHANNEL_CONFIG_REAL_PATH"
    sed -i 's/AS_923_925/AS_923_1/g' "$CHANNEL_CONFIG_REAL_PATH"
fi

# Update AS923/AS_923_925_TTN_AU.toml to AS923/AS_923_2.toml
if grep -q "AS_923_925_TTN_AU" "$CHANNEL_CONFIG_REAL_PATH"; then
    log $PREFIX "Updating AS923_925_TTN_AU to AS923_2 in $CHANNEL_CONFIG_REAL_PATH"
    sed -i 's/AS_923_925_TTN_AU/AS_923_2/g' "$CHANNEL_CONFIG_REAL_PATH"
fi

# Update RU864/RU_864_870_TTN.toml to RU864/RU_864_870.toml
if grep -q "RU_864_870_TTN" "$CHANNEL_CONFIG_REAL_PATH"; then
    log $PREFIX "Updating RU_864_870_TTN to RU_864_870 in $CHANNEL_CONFIG_REAL_PATH"
    sed -i 's/RU_864_870_TTN/RU_864_870/g' "$CHANNEL_CONFIG_REAL_PATH"
fi

log $PREFIX "Migration done"

exit 0

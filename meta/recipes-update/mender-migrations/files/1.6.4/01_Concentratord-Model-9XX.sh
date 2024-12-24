#!/bin/sh

### CONFIGURE THE MIGRATION ###

# The prefix will be shown in the logs only. Keep it short. E.g. "NM-PROF-MV"
PREFIX=CSCD-MODEL-9XX

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
VERSION_MAX="1.6.4"

# Condition that will be finally be checked to know if the migration will be applied.
# Is automatically generated with VERSION_MIN and VERSION_MAX if not defined. If defined VERSION_MIN/MAX are ignored
#MIGRATION_CONDITION=">=0.4.0 <0.6.1" 

### DO NO CHANGE THE FOLLOWING TWO LINES ###

# Load the work variables (do not change)
# - $S_ETC : current etc diff, readonly (/data/layers/config/rootfs[A|B])
# - $D_ETC : current etc diff, readwrite (/data/layers/config/rootfs[A|B] mounted on /var/lib/manager/migration)
# - $S_ROOT : factory root of the active partition, readonly (/data/layers/factory)
source /data/mender/upgrade/migration-env.sh 

# Checks wheteher the migration should be applied or not (do not change)
source /data/mender/upgrade/version-guard.sh

### WRITE YOUR MIGRATION FROM HERE ###

# You may generally want to go into /etc of the destination rootfs. 
# WARNING - Path to files MUST not contain /etc (would refer to the currently mounted config)
cd $D_ETC

CSCD_PATH="opt/chirpstack-concentratord"
CSCD_CONFIG_PATH="$CSCD_PATH/10-gateway.toml" # Refers to /etc/opt/chirpstack-concentratord/10-gateway.toml

# It is generally a good thing to check wheter the migration should be applied or not depending on the FS state
if [[ ! -f "$CSCD_CONFIG_PATH" ]]; then
    log $PREFIX "No configuration file found at $CSCD_CONFIG_PATH, skipping migration."
    exit 0
fi

log $PREFIX "Migrating..."

# The migration steps will depend on the type of migration. Prefer post-migration.
# - Pre-migration : copy files from $S_ETC to $D_ETC, edit them but not rename them
# - Post-migration : add, edit or remove files in $D_ETC

# retrieve LoRa frequency from machine-info
LORA_FREQUENCY=$(machine-info -n -f "PRODUCT_FREQUENCY")

# If LoRa frequency is not 902-928, skip migration
if [[ "$LORA_FREQUENCY" != "902-928" ]]; then
    log $PREFIX "LoRa frequency is not 902-928, skipping migration."
    exit 0
fi

PRODUCT_MODEL=$(machine-info -n -f "PRODUCT_MODEL")

# replace "-" with "_"
LORA_FREQUENCY=${LORA_FREQUENCY//-/_}
PRODUCT_MODEL=${PRODUCT_MODEL//-/_}

MODEL="wifx_${PRODUCT_MODEL}_${LORA_FREQUENCY}"

sed -i -r 's/model=".*"/model="'${MODEL}'"/g' $CSCD_CONFIG_PATH

log $PREFIX "Model set to "$MODEL" in file "$CSCD_CONFIG_PATH

log $PREFIX "Migration done"

exit 0

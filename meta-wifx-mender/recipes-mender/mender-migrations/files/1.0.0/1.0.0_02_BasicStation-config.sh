#!/bin/sh

### CONFIGURE THE MIGRATION ###

# The prefix will be shown in the logs only. Keep it short. E.g. "NM-PROF-MV"
PREFIX=BASIC-STATION-CFG 

# The following versions description uses semver: https://semver.org/
# Condition syntax is defined by semver_rs "Range" object: https://docs.rs/semver_rs/0.1.3/semver_rs/struct.Range.html.

# Defines what is the lowest version (included) of the source system for the migration to be applied (semver).
# You should set this if an old version does not have the software/files you try to migrate.
# WARNING: rember that a beta/rc is older (<) than a release
# Must not be empty. Can be left undefined.
# VERSION_MIN="0.6.0" 

# Defines what is the highest version (excluded) of the source system for the migration to be applied (semver).
# This is generally set to the current version. If the user has this version (or higher), the migration is done and not usefull anymore.
# Must not be empty. Can be left undefined.
VERSION_MAX="1.0.0" 

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

ANTENNA_TYPE_FILE_PATH="manager/antennaType"

BASICSTATION_PATH="opt/lora-basic-station"
BASICSTATION_CONFIG_PATH="$BASICSTATION_PATH/station.conf" # Refers to /etc/opt/lora-basic-station/station.conf

# It is generally a good thing to check wheter the migration should be applied or not depending on the FS state
if [[ -f "$BASICSTATION_CONFIG_PATH" ]]; then
    log $PREFIX "Basic station configuration already exists, skipping migration"
    exit 0
fi

log $PREFIX "Migrating..."

# The migration steps will depend on the type of migration. Prefer post-migration.
# - Pre-migration : copy files from $S_ETC to $D_ETC, edit them but not rename them
# - Post-migration : add, edit or remove files in $D_ETC

PRODUCT_TYPE=`cat /sys/class/product/machine/product_type`
if [[ "$PRODUCT_TYPE" == "EU868" ]]; then
    HARDWARE="863-870"
elif  [[ "$PRODUCT_TYPE" == "US915" || "$PRODUCT_TYPE" == "AU915" ]]; then
    HARDWARE="902-928"
else
    log $PREFIX "Unknown product type '$PRODUCT_TYPE', skipping migration"
    exit 0
fi
log $PREFIX "Detected hardware: '$HARDWARE'"

if [[ ! -f "$ANTENNA_TYPE_FILE_PATH" ]]; then
    log $PREFIX "Antenna type is not configured, cannot set config, skipping migration"
    exit 0
fi

ANTENNA_TYPE=`cat /etc/manager/antennaType`
if [[ "$ANTENNA_TYPE" == "2dbi" || "$ANTENNA_TYPE" == "indoor" ]]; then
    ANTENNA="2dBi"
elif  [[ "$ANTENNA_TYPE" == "4dbi" || "$ANTENNA_TYPE" == "outdoor" ]]; then
    ANTENNA="4dBi"
else
    log $PREFIX "Unknown antenna type '$ANTENNA_TYPE', skipping migration"
    exit 0
fi
log $PREFIX "Detected antenna: '$ANTENNA'"

CONFIG_FILE_RELATIVE_PATH="config/$HARDWARE/station_$ANTENNA.conf"

CONFIG_FILE_PATH="$BASICSTATION_PATH/$CONFIG_FILE_RELATIVE_PATH"

log $PREFIX "Set active config to '$CONFIG_FILE_PATH'"
mkdir -p -m 644 "$BASICSTATION_PATH"
ln -sf "$CONFIG_FILE_RELATIVE_PATH" "$BASICSTATION_CONFIG_PATH"
if [[ $? != 0 ]]; then
    log $PREFIX "Could not create configuration file link"
    log $PREFIX "ln -sf \"$CONFIG_FILE_RELATIVE_PATH\" \"$BASICSTATION_CONFIG_PATH\""
    exit 1
fi

log $PREFIX "Migration done"

exit 0

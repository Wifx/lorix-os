#!/bin/sh

### CONFIGURE THE MIGRATION ###

# The prefix will be shown in the logs only. Keep it short. E.g. "NM-PROF-MV"
PREFIX=GPS-DISABLE

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
VERSION_MAX="1.1.1" 

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

UPF_CONFIG="$D_ETC/opt/udp-packet-forwarder"

# It is generally a good thing to check wheter the migration should be applied or not depending on the FS state
if [[ ! -d "$UPF_CONFIG" ]]; then
    log $PREFIX "No config to migrate"
    exit 0
fi

log $PREFIX "Migrating..."

# The migration steps will depend on the type of migration. Prefer post-migration.
# - Pre-migration : copy files from $S_ETC to $D_ETC, edit them but not rename them
# - Post-migration : add, edit or remove files in $D_ETC

sed -i 's|Only fake gps is supported, should stay to true|Enable if you want the below coordinates to be sent to the server|' $UPF_CONFIG/gateway/**/*.json

FILES=$(find $UPF_CONFIG -name "gateway_local_conf.json")

for FILE in $FILES
do
    log $PREFIX "Checking $FILE"

    grep '"fake_gps": true' $FILE
    if [[ $? != 0 ]]; then
        continue
    fi;
        
    grep '"ref_latitude": -1' $FILE
    if [[ $? != 0 ]]; then
        continue
    fi;

    grep '"ref_longitude": -1' $FILE
    if [[ $? != 0 ]]; then
        continue
    fi;

    grep '"ref_altitude": -1' $FILE
    if [[ $? != 0 ]]; then
        continue
    fi;

    log $PREFIX "Disabling fake GPS in $FILE"
    sed -i 's|"fake_gps": true|"fake_gps": false|' $FILE

done

log $PREFIX "Migration done"

exit 0

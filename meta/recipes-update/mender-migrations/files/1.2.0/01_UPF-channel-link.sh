#!/bin/sh

### CONFIGURE THE MIGRATION ###

# The prefix will be shown in the logs only. Keep it short. E.g. "NM-PROF-MV"
PREFIX=UPF-CHAN

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
VERSION_MAX="1.2.0" 

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

UPF_CHAN_DIR="$D_ETC/opt/udp-packet-forwarder/channels"
UPF_CHAN_CFG="$UPF_CHAN_DIR/channels_conf.json"

# It is generally a good thing to check wheter the migration should be applied or not depending on the FS state
if [[ ! -L "$UPF_CHAN_CFG" ]]; then
    log $PREFIX "No channel config to migrate"
    exit 0
fi

log $PREFIX "Migrating..."

# The migration steps will depend on the type of migration. Prefer post-migration.
# - Pre-migration : copy files from $S_ETC to $D_ETC, edit them but not rename them
# - Post-migration : add, edit or remove files in $D_ETC

CURRENT_CANNEL=$(readlink $UPF_CHAN_CFG)
log $PREFIX "Channel config is '$CURRENT_CANNEL'"

# /etc/opt/udp-packet-forwarder/channels/EU868/channels_conf_EU868_LoRaWAN.json
# AS1/channels_conf_AS1_TTN.json => AS920/AS_920_923.json
# AS2/channels_conf_AS2_TTN.json => AS923/AS_923_925.json
# AU915/channels_conf_AU915_LoRaWAN.json => AU915/AU_915_928_FSB_2.json
# EU868/channels_conf_EU868_LoRaWAN.json => EU868/EU_863_870.json
# US915/channels_conf_US915_LoRaWAN.json => US915/US_902_928_FSB_1.json

# Make relative
ABS_BASE_PATH="/etc/opt/udp-packet-forwarder/channels/"
CURRENT_CANNEL=${CURRENT_CANNEL#"$ABS_BASE_PATH"}

# Check if the channel file exists in user config (this would mean it has been edited)
if [[ -f "$UPF_CHAN_DIR/$CURRENT_CANNEL" ]]; then
    log $PREFIX "Configured channel exists in overlay, not migrating"
    exit 0
fi

# Use new channel
case $CURRENT_CANNEL in

    "AS1/channels_conf_AS1_TTN.json")
        NEW_CHANNEL="AS920/AS_920_923.json"
        ;;

    "AS2/channels_conf_AS2_TTN.json")
        NEW_CHANNEL="AS923/AS_923_925.json"
        ;;

    "AU915/channels_conf_AU915_LoRaWAN.json")
        NEW_CHANNEL="AU915/AU_915_928_FSB_2.json"
        ;;

    "EU868/channels_conf_EU868_LoRaWAN.json")
        NEW_CHANNEL="EU868/EU_863_870.json"
        ;;

    "US915/channels_conf_US915_LoRaWAN.json")
        NEW_CHANNEL="US915/US_902_928_FSB_1.json"
        ;;

    *)
        log $PREFIX "Unknown configured channel, not migrating"
        exit 0
        ;;
esac

# Migrate channel config (use the relative target)
log $PREFIX "Defining channel config to '$NEW_CHANNEL'"
ln -snf $NEW_CHANNEL $UPF_CHAN_CFG

log $PREFIX "Migration done"

exit 0

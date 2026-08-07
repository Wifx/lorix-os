#!/bin/sh -e

### CONFIGURE THE MIGRATION ###

# The prefix will be shown in the logs only. Keep it short. E.g. "NM-PROF-MV"
PREFIX=CSCD-V4-SETUP

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

LEGACY_CHANNELS_LINK="opt/chirpstack-concentratord-legacy/channels/channels.toml"
CHANNELS_DIR="opt/chirpstack-concentratord/channels"
CHANNELS_LINK="opt/chirpstack-concentratord/channels/channels.toml"
GATEWAY_CONFIG="opt/chirpstack-concentratord/10-gateway.toml"
LEGACY_GATEWAY_CONFIG="opt/chirpstack-concentratord-legacy/10-gateway.toml"

# Factory root of the inactive (destination) partition
GATEWAY_TEMPLATE="${LAYER_FACTORY_INACTIVE}/etc/opt/chirpstack-concentratord/10-gateway.toml"

### Create channels symlink ###

if [[ ! -L "$LEGACY_CHANNELS_LINK" ]]; then
    log $PREFIX "No legacy channels symlink found, skipping channel link creation"
else
    LEGACY_TARGET=$(readlink "$LEGACY_CHANNELS_LINK")

    # Apply same name migrations as the frequency plan migration
    NEW_TARGET=$(echo "$LEGACY_TARGET" | sed \
        -e 's/AS_923_925_TTN_AU/AS_923_2/g' \
        -e 's/AS_923_925/AS_923_1/g' \
        -e 's/RU_864_870_TTN/RU_864_870/g')

    mkdir -p "$CHANNELS_DIR"
    ln -snf "$NEW_TARGET" "$CHANNELS_LINK"
    log $PREFIX "Created channels symlink -> $NEW_TARGET"
fi

### L1-only gateway config setup ###

LORA_FRONTEND_REV=$(machine-info read "LORA_IFACE_0_FRONTEND_REV" 2>/dev/null || true)
if [[ -z "$LORA_FRONTEND_REV" ]]; then
    log $PREFIX "Not an L1 gateway, skipping gateway config setup"
    log $PREFIX "Migration done"
    exit 0
fi

if [[ ! -f "$GATEWAY_TEMPLATE" ]]; then
    log $PREFIX "ERROR: Gateway template not found at $GATEWAY_TEMPLATE"
    exit 1
fi

cp "$GATEWAY_TEMPLATE" "$GATEWAY_CONFIG"
chmod 0644 "$GATEWAY_CONFIG"
log $PREFIX "Gateway config initialized from template"

### Set region ###

if [[ -L "$CHANNELS_LINK" ]]; then
    CHANNEL_TARGET=$(readlink "$CHANNELS_LINK")
    REGION_DIR=$(echo "$CHANNEL_TARGET" | cut -d'/' -f1)
    PLAN_FILE=$(basename "$CHANNEL_TARGET" .toml)

    case "$REGION_DIR" in
        AS920)
            log $PREFIX "ERROR: AS920 region is not supported, manual migration required"
            exit 1
            ;;
        AS923)
            # Determine sub-band from plan filename suffix (e.g. AS_923_2 -> AS923_2)
            case "$PLAN_FILE" in
                *_2) REGION="AS923_2" ;;
                *_3) REGION="AS923_3" ;;
                *_4) REGION="AS923_4" ;;
                *)   REGION="AS923" ;;
            esac
            ;;
        *)
            REGION="$REGION_DIR"
            ;;
    esac

    sed -i "s/region=\"\"/region=\"$REGION\"/" "$GATEWAY_CONFIG"
    log $PREFIX "Region set to '$REGION'"
fi

### Model flags ###

# Completed by OPKG configure and postinst scripts, no need to migrate here

### Antenna gain ###

if [[ -f "$LEGACY_GATEWAY_CONFIG" ]]; then
    ANTENNA_GAIN=$(sed -n 's/.*antenna_gain=\([0-9.-]*\).*/\1/p' "$LEGACY_GATEWAY_CONFIG" | head -n 1)
    if [[ -n "$ANTENNA_GAIN" && "$ANTENNA_GAIN" != "0" ]]; then
        sed -i "s/antenna_gain=0/antenna_gain=${ANTENNA_GAIN}/" "$GATEWAY_CONFIG"
        log $PREFIX "Antenna gain set to '$ANTENNA_GAIN'"
    else
        log $PREFIX "Antenna gain unchanged (legacy value: '${ANTENNA_GAIN:-not found}')"
    fi
fi

log $PREFIX "Migration done"

exit 0

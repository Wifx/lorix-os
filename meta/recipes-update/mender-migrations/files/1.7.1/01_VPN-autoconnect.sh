#!/bin/sh -e

### CONFIGURE THE MIGRATION ###

# The prefix will be shown in the logs only. Keep it short. E.g. "NM-PROF-MV"
PREFIX=VPN-AUTOCONNECT 

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
VERSION_MAX="1.7.1" 

# Condition that will be finally be checked to know if the migration will be applied.
# Is automatically generated with VERSION_MIN and VERSION_MAX if not defined. If defined VERSION_MIN/MAX are ignored
#MIGRATION_CONDITION=">=0.4.0 <0.6.1" 

### DO NO CHANGE THE FOLLOWING TWO LINES ###

# Load the work variables (do not change)
# - $S_ETC : active etc diff, readonly (/var/lib/os/layers/active/config)
# - $D_ETC : inactive etc diff, readwrite (/var/lib/os/layers/inactive/config mounted on /var/lib/migration/config)
# - $S_ROOT : factory root of the active partition, readonly (/var/lib/os/layers/active/factory)
source /data/mender/upgrade/migration-env.sh 

# Checks wheteher the migration should be applied or not (do not change)
source /data/mender/upgrade/version-guard.sh

### WRITE YOUR MIGRATION FROM HERE ###

# You may generally want to go into /etc of the destination rootfs. 
# WARNING - Path to files MUST not contain /etc (would refer to the currently mounted config)
cd $D_ETC

ETH0_CONFIG_PATH="NetworkManager/system-connections/backhaul.nmconnection"
VPN_AUTOCONNECT_DIR_PATH="NetworkManager/vpn-autoconnect"
VPN_AUTOCONNECT_CONFIG_DIR="config"
VPN_AUTOCONNECT_CONFIG_DIR_PATH="$VPN_AUTOCONNECT_DIR_PATH/$VPN_AUTOCONNECT_CONFIG_DIR"
VPN_AUTOCONNECT_ENABLED_DIR_PATH="$VPN_AUTOCONNECT_DIR_PATH/enabled"

# Check if the Ethernet configuration file exists
if [ ! -f "$ETH0_CONFIG_PATH" ]; then
    log $PREFIX "No config to migrate at $ETH0_CONFIG_PATH"
    exit 0
fi

log $PREFIX "Migrating..."

# Extract the UUID
UUID=$(grep "^uuid=" "$ETH0_CONFIG_PATH" | cut -d'=' -f2)
if [ -z "$UUID" ]; then
    log $PREFIX "No UUID found in $ETH0_CONFIG_PATH"
    exit 1
fi

# Extract the secondaries and remove the line from the file
SECONDARIES=$(grep "^secondaries=" "$ETH0_CONFIG_PATH" | cut -d'=' -f2)
if [ -z "$SECONDARIES" ]; then
    log $PREFIX "No secondaries found in $ETH0_CONFIG_PATH, ending migration"
    exit 0
else
    sed -i '/^secondaries=/d' "$ETH0_CONFIG_PATH"
fi

# Convert the comma-separated values into an array
IFS=';' read -r -a SECONDARIES_ARRAY <<< "$SECONDARIES"

# Create required directories if they don't exist
mkdir -p "$VPN_AUTOCONNECT_CONFIG_DIR_PATH" || {
    log $PREFIX "Failed to create directory $VPN_AUTOCONNECT_CONFIG_DIR_PATH"
    exit 1
}
mkdir -p "$VPN_AUTOCONNECT_ENABLED_DIR_PATH" || {
    log $PREFIX "Failed to create directory $VPN_AUTOCONNECT_ENABLED_DIR_PATH"
    exit 1
}

# Write each secondary value to the VPN auto-connect config file
for secondary in "${SECONDARIES_ARRAY[@]}"; do
    # Skip if secondary is empty
    [ -z "$secondary" ] && continue
    
    echo "$UUID" >> "$VPN_AUTOCONNECT_CONFIG_DIR_PATH/$secondary" || {
        log $PREFIX "Failed to write secondary $secondary to $VPN_AUTOCONNECT_CONFIG_DIR_PATH/$UUID"
        exit 1
    }

    # Enable the VPN auto-connect for this connection only if there are secondaries
    ln -sf "../$VPN_AUTOCONNECT_CONFIG_DIR/$secondary" "$VPN_AUTOCONNECT_ENABLED_DIR_PATH/$secondary" || {
        log $PREFIX "Failed to enable VPN auto-connect for $secondary"
        exit 1
    }
    log $PREFIX "VPN auto-connect enabled for $secondary"

done

log $PREFIX "Migration done"

exit 0

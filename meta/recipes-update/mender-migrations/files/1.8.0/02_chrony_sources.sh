#!/bin/sh -e

### CONFIGURE THE MIGRATION ###

# The prefix will be shown in the logs only. Keep it short. E.g. "NM-PROF-MV"
PREFIX=CHRONY-SOURCES 

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

CHRONY_CONFIG_PATH="chrony.conf"
CHRONY_SOURCES_DIR="chrony/sources.d"
CHRONY_SOURCES_POOL_PATH="$CHRONY_SOURCES_DIR/default-pool.sources"
CHRONY_SOURCES_CUSTOM_PATH="$CHRONY_SOURCES_DIR/custom-servers.sources"

# It is generally a good thing to check wheter the migration should be applied or not depending on the FS state
if [[ ! -f "$CHRONY_CONFIG_PATH" ]]; then
    log $PREFIX "No config to migrate"
    exit 0
fi

log $PREFIX "Migrating chrony configuration to sources files..."

# Create chrony sources directory if it doesn't exist
if ! mkdir -p "$CHRONY_SOURCES_DIR"; then
    log $PREFIX "ERROR: Failed to create directory $CHRONY_SOURCES_DIR"
    exit 1
fi

# Extract pool entries from chrony.conf
POOLS_FOUND=$(grep -E "^\s*pool\s+" "$CHRONY_CONFIG_PATH" 2>/dev/null || true)
if [ -n "$POOLS_FOUND" ]; then
    log $PREFIX "Found pool entries, creating $CHRONY_SOURCES_POOL_PATH"
    if echo "$POOLS_FOUND" > "$CHRONY_SOURCES_POOL_PATH"; then
        log $PREFIX "Extracted $(echo "$POOLS_FOUND" | wc -l) pool entries"
    else
        log $PREFIX "ERROR: Failed to write pool entries to $CHRONY_SOURCES_POOL_PATH"
        exit 1
    fi
else
    log $PREFIX "No pool entries found in chrony.conf"
fi

# Extract server entries from chrony.conf
SERVERS_FOUND=$(grep -E "^\s*server\s+" "$CHRONY_CONFIG_PATH" 2>/dev/null || true)
if [ -n "$SERVERS_FOUND" ]; then
    log $PREFIX "Found server entries, creating $CHRONY_SOURCES_CUSTOM_PATH"
    if echo "$SERVERS_FOUND" > "$CHRONY_SOURCES_CUSTOM_PATH"; then
        log $PREFIX "Extracted $(echo "$SERVERS_FOUND" | wc -l) server entries"
    else
        log $PREFIX "ERROR: Failed to write server entries to $CHRONY_SOURCES_CUSTOM_PATH"
        exit 1
    fi
else
    log $PREFIX "No server entries found in chrony.conf"
fi

# Add sourcedir directive to chrony.conf if not already present
if ! grep -q "^\s*sourcedir\s" "$CHRONY_CONFIG_PATH" 2>/dev/null; then
    log $PREFIX "Adding sourcedir directive to chrony.conf"
    echo "" >> "$CHRONY_CONFIG_PATH"
    echo "# Source files directory for dynamic NTP sources" >> "$CHRONY_CONFIG_PATH"
    echo "sourcedir /etc/chrony/sources.d" >> "$CHRONY_CONFIG_PATH"
    echo "sourcedir /var/run/chrony-dhcp" >> "$CHRONY_CONFIG_PATH"
else
    log $PREFIX "sourcedir directive already exists in chrony.conf"
fi

# Set appropriate permissions
if [ -f "$CHRONY_SOURCES_POOL_PATH" ]; then
    chmod 644 "$CHRONY_SOURCES_POOL_PATH"
fi
if [ -f "$CHRONY_SOURCES_CUSTOM_PATH" ]; then
    chmod 644 "$CHRONY_SOURCES_CUSTOM_PATH"
fi

log $PREFIX "Removing old chrony.conf file"
if rm -f "$CHRONY_CONFIG_PATH"; then
    log $PREFIX "Successfully removed old chrony.conf"
else
    log $PREFIX "ERROR: Failed to remove $CHRONY_CONFIG_PATH"
    exit 1
fi

log $PREFIX "Migration completed successfully"

exit 0

#!/bin/sh -e

### CONFIGURE THE MIGRATION ###

# The prefix will be shown in the logs only. Keep it short. E.g. "NM-PROF-MV"
PREFIX=IPTABLES-NFTABLES 

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

IPTABLES_CONFIG_PATH="iptables/iptables.rules"
IP6TABLES_CONFIG_PATH="iptables/ip6tables.rules"

NFTABLES_CONFIG_DIR="nftables"
NFTABLES_AVAILABLE_SET_DIR="${NFTABLES_CONFIG_DIR}/available"
NFTABLES_ACTIVE_SET_DIR="${NFTABLES_CONFIG_DIR}/conf.d"

# It is generally a good thing to check wheter the migration should be applied or not depending on the FS state
if [[ ! -f "$IPTABLES_CONFIG_PATH" && ! -f "$IP6TABLES_CONFIG_PATH" ]]; then
    log $PREFIX "No config to migrate"
    exit 0
fi

log $PREFIX "Migrating..."

if [[ -f "$IPTABLES_CONFIG_PATH" ]]; then
    log $PREFIX "Found iptables config, migrating to nftables"

    # Check if file contains SNMP accept "-A INPUT -p udp -m udp --dport 161 -j ACCEPT"
    if grep -q -- "-A INPUT -p udp -m udp --dport 161 -j ACCEPT" "$IPTABLES_CONFIG_PATH"; then
        log $PREFIX "Found SNMP rule, adding nftables config"

        # Add nftables config for SNMP
        if ! mkdir -p "${NFTABLES_ACTIVE_SET_DIR}"; then
            log $PREFIX "ERROR: Failed to create directory ${NFTABLES_ACTIVE_SET_DIR}"
            exit 1
        fi
        
        if ln -snf "/etc/${NFTABLES_AVAILABLE_SET_DIR}/snmp.conf" "${NFTABLES_ACTIVE_SET_DIR}/90-snmp.conf"; then
            log $PREFIX "Successfully created symlink for SNMP config"
        else
            log $PREFIX "ERROR: Failed to create symlink for SNMP config"
            exit 1
        fi
    fi

    # Backup iptables config file
    if mv "$IPTABLES_CONFIG_PATH" "${IPTABLES_CONFIG_PATH}.bak"; then
        log $PREFIX "Backed up obsolete iptables config to ${IPTABLES_CONFIG_PATH}.bak"
    else
        log $PREFIX "ERROR: Failed to backup iptables config"
        exit 1
    fi
fi

if [[ -f "$IP6TABLES_CONFIG_PATH" ]]; then
    log $PREFIX "Found ip6tables config, migrating to nftables"
    # Backup ip6tables config file
    if mv "$IP6TABLES_CONFIG_PATH" "${IP6TABLES_CONFIG_PATH}.bak"; then
        log $PREFIX "Backed up obsolete ip6tables config to ${IP6TABLES_CONFIG_PATH}.bak"
    else
        log $PREFIX "ERROR: Failed to backup ip6tables config"
        exit 1
    fi
fi

log $PREFIX "Migration done"

exit 0

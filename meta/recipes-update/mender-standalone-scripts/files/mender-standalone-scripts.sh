#!/bin/sh

# Copyright (c) 2025, Wifx Sàrl <info@wifx.net>
# All rights reserved.

SCRIPTS_PATH="/data/mender/scripts"

function log {
    echo "$1"
}

# Check if an update is pending
UPGRADE_AVAILABLE=$(fw_printenv upgrade_available -n)
if [ $? -ne 0 ]; then
    log "Error reading upgrade_available"
    exit 1
fi

# If no upgrade is pending, exit
if [ "$UPGRADE_AVAILABLE" != "1" ]; then
    log "Not starting an updated system (not pending)"
    log "Checking update status"
    if [ -f /data/mender/upgrade/migration-env.sh ]; then
        log "Update in progress, executing rollback..."
        mender-update rollback
    else
        log "No update in progress"
    fi
    exit 0
fi

log "An update is pending"

# Read prefix from args and check
if [ -z "$1" ]; then
    log "No scripts prefix provided. Usage $0 <scripts_prefix>"
    exit 1
fi
SCRIPTS_PREFIX="$1"

# Check if mender-update is available
if ! command -v mender-update &> /dev/null; then
    log "mender-update not found"
    exit 1
fi

log "Executing $SCRIPTS_PREFIX tasks for pending update"

# Execute all files starting with prefix in /data/mender/scripts
for script in $SCRIPTS_PATH/$SCRIPTS_PREFIX*; do
    if [ -f "$script" ] && [ -x "$script" ]; then

        # Execute script and log its output
        log "Executing $script"
        $script
        
        # If script fails, rollback the update
        if [ $? -ne 0 ]; then
            log "Error executing $script"
            log "Rolling back update"
            mender-update rollback
            log "Rebooting"
            shutdown -r now "The extra $SCRIPTS_PREFIX tasks of the pending update failed" 
            exit 0
        fi
    fi
done

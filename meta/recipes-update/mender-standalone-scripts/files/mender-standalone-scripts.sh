#!/bin/sh

# Copyright (c) 2025, Wifx SA <info@wifx.net>
# All rights reserved.

SCRIPTS_PATH="/data/mender/scripts"
LOG_FILENAME="$(date -u +'%Y-%m-%dT%H:%M:%SZ')-mender-standalone-scripts.log"
LOG_DIR="/var/log/upgrade"
LOG_FILE="$LOG_DIR/$LOG_FILENAME"
LOG_PERSISTENT_DIR="/data/mender/upgrade/logs"
INHIBIT_FILE_PATH="/data/mender/upgrade/inhibit-reboot-script-standalone"

log() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> "$LOG_FILE"
}

# Check if process is inhibited
if [ -f "$INHIBIT_FILE_PATH" ]; then
    log "Reboot script is inhibited by $INHIBIT_FILE_PATH"
    exit 0
fi

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
            if [ $? -ne 0 ]; then
                log "Failed to rollback update"
            fi

            # Create persistent log directory if it does not exist
            if [ ! -d "$LOG_PERSISTENT_DIR" ]; then
                mkdir -p "$LOG_PERSISTENT_DIR"

                if [ $? -ne 0 ]; then
                    log "Failed to create persistent log directory at $LOG_PERSISTENT_DIR"
                fi
            fi

            # Save log files
            if [ ! -d "$LOG_PERSISTENT_DIR" ]; then
                cp "$LOG_FILE" "$LOG_PERSISTENT_DIR/$LOG_FILENAME"
                if [ $? -ne 0 ]; then
                    log "Failed to save log file to persistent storage"
                else
                    log "Log file saved to $LOG_PERSISTENT_DIR"
                fi
            fi

            log "Rollback completed, rebooting system"
            shutdown -r now "The extra $SCRIPTS_PREFIX tasks of the pending update failed" 
            exit 0
        fi
    fi
done

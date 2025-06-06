#!/bin/sh

PREFIX=MIGRATE-OPKG-STATUS-APPLY
source /data/mender/upgrade/migration-env.sh

FACTORY_OPKG_STATUS_FILE="$S_ROOT/var/lib/opkg/status"
USER_OPKG_STATUS_FILE="/var/lib/opkg/status"
OPKG_STATUS_DIFF_BIN="/data/mender/upgrade/tools/opkg-status-diff"
OPKG_STATUS_PATCHES_DIR="/data/mender/upgrade/opkg-status-patches"

if [ ! -f "$USER_OPKG_STATUS_FILE" ]; then
    log $PREFIX "No existing user opkg status file found, skipping migration"
    exit 0
fi

if [ ! -x "$OPKG_STATUS_DIFF_BIN" ]; then
    log $PREFIX "OPKG status diff binary not found or not executable: $OPKG_STATUS_DIFF_BIN"
    exit 1
fi

log $PREFIX "Backing up existing user opkg status file"
mv -f "$USER_OPKG_STATUS_FILE" "$USER_OPKG_STATUS_FILE.bak"
if [ $? -ne 0 ]; then
    log $PREFIX "Failed to backup user opkg status file"
    exit 1
fi

# Check if the patches directory exists
if [ ! -d "$OPKG_STATUS_PATCHES_DIR" ]; then
    log $PREFIX "OPKG status patches directory does not exist: $OPKG_STATUS_PATCHES_DIR"
    exit 1
fi

if [ ! -f "$FACTORY_OPKG_STATUS_FILE" ]; then
    log $PREFIX "Factory opkg status file not found: $FACTORY_OPKG_STATUS_FILE"
    exit 1
fi

# Copy factory opkg status file to user directory
log $PREFIX "Copying factory opkg status file to user directory"
cp -f "$FACTORY_OPKG_STATUS_FILE" "$USER_OPKG_STATUS_FILE"
if [ $? -ne 0 ]; then
    log $PREFIX "Failed to copy factory opkg status file to user directory"
    exit 1
fi

TEMP_STATUS_FILE_APPLY="" # Initialize, will hold mktemp result

# Function to clean up temporary file
cleanup_temp_file() {
    if [ -n "$TEMP_STATUS_FILE_APPLY" ] && [ -f "$TEMP_STATUS_FILE_APPLY" ]; then
        log $PREFIX "Cleaning up temporary file: $TEMP_STATUS_FILE_APPLY"
        rm -f "$TEMP_STATUS_FILE_APPLY"
    fi
}

# Setup trap for cleanup on exit or interrupt
trap cleanup_temp_file EXIT HUP INT QUIT TERM

log $PREFIX "Applying OPKG status patches to user opkg status file"

if [ -f "$OPKG_STATUS_PATCHES_DIR/packages-added.patch" ]; then
    log $PREFIX "Applying added packages patch..."
    TEMP_STATUS_FILE_APPLY=$(mktemp "$USER_OPKG_STATUS_FILE.apply.XXXXXX")
    if [ $? -ne 0 ] || [ -z "$TEMP_STATUS_FILE_APPLY" ]; then
        log $PREFIX "Error: Failed to create temporary file for 'added' patch."
        # Trap will attempt cleanup if TEMP_STATUS_FILE_APPLY was partially set
        exit 1
    fi

    if "$OPKG_STATUS_DIFF_BIN" apply added "$USER_OPKG_STATUS_FILE" "$OPKG_STATUS_PATCHES_DIR/packages-added.patch" > "$TEMP_STATUS_FILE_APPLY"; then
        if mv "$TEMP_STATUS_FILE_APPLY" "$USER_OPKG_STATUS_FILE"; then
            log $PREFIX "Successfully applied added packages."
            TEMP_STATUS_FILE_APPLY="" # Clear variable as file has been moved
        else
            log $PREFIX "Error: Failed to move patched (added) status file from $TEMP_STATUS_FILE_APPLY to $USER_OPKG_STATUS_FILE."
            # Trap will clean up TEMP_STATUS_FILE_APPLY
            exit 1
        fi
    else
        log $PREFIX "Error: Failed to apply added packages patch using $OPKG_STATUS_DIFF_BIN."
        # Trap will clean up TEMP_STATUS_FILE_APPLY
        exit 1
    fi
else
    log $PREFIX "No added packages patch found, skipping addition"
fi

if [ -f "$OPKG_STATUS_PATCHES_DIR/packages-removed.patch" ]; then
    log $PREFIX "Applying removed packages patch..."
    TEMP_STATUS_FILE_APPLY=$(mktemp "$USER_OPKG_STATUS_FILE.apply.XXXXXX")
    if [ $? -ne 0 ] || [ -z "$TEMP_STATUS_FILE_APPLY" ]; then
        log $PREFIX "Error: Failed to create temporary file for 'removed' patch."
        exit 1
    fi

    if "$OPKG_STATUS_DIFF_BIN" apply removed "$USER_OPKG_STATUS_FILE" "$OPKG_STATUS_PATCHES_DIR/packages-removed.patch" > "$TEMP_STATUS_FILE_APPLY"; then
        if mv "$TEMP_STATUS_FILE_APPLY" "$USER_OPKG_STATUS_FILE"; then
            log $PREFIX "Successfully applied removed packages."
            TEMP_STATUS_FILE_APPLY="" # Clear variable as file has been moved
        else
            log $PREFIX "Error: Failed to move patched (removed) status file from $TEMP_STATUS_FILE_APPLY to $USER_OPKG_STATUS_FILE."
            exit 1
        fi
    else
        log $PREFIX "Error: Failed to apply removed packages patch using $OPKG_STATUS_DIFF_BIN."
        exit 1
    fi
else
    log $PREFIX "No removed packages patch found, skipping removal"
fi

# All operations successful, remove the trap and perform final cleanup if any temp file was missed (should not happen)
trap - EXIT HUP INT QUIT TERM
cleanup_temp_file # Explicit call in case TEMP_STATUS_FILE_APPLY still holds a path (e.g. if no patches applied)

log $PREFIX "OPKG status migration patches applied successfully"
exit 0

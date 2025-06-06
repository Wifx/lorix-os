#!/bin/sh

PREFIX=MIGRATE-OPKG-STATUS-DIFF
source /data/mender/upgrade/migration-env.sh

FACTORY_OPKG_STATUS_FILE="$S_ROOT/var/lib/opkg/status"
USER_OPKG_STATUS_FILE="$LAYER_USER/var/lib/opkg/status"
OPKG_STATUS_DIFF_BIN="/data/mender/upgrade/tools/opkg-status-diff"
OPKG_STATUS_PATCHES_DIR="/data/mender/upgrade/opkg-status-patches"

# Check if user opkg status file exists
if [ ! -f "$USER_OPKG_STATUS_FILE" ]; then
    log $PREFIX "No existing user opkg status file found, skipping migration"
    exit 0
fi

# Check binary existence
if [ ! -x "$OPKG_STATUS_DIFF_BIN" ]; then
    log $PREFIX "OPKG status diff binary not found or not executable: $OPKG_STATUS_DIFF_BIN"
    exit 1
fi

# Create patches directory if it doesn't exist
if [ ! -d "$OPKG_STATUS_PATCHES_DIR" ]; then
    log $PREFIX "Creating OPKG status patches directory: $OPKG_STATUS_PATCHES_DIR"
    mkdir -p "$OPKG_STATUS_PATCHES_DIR"
    if [ $? -ne 0 ]; then
        log $PREFIX "Failed to create OPKG status patches directory"
        exit 1
    fi
fi

$OPKG_STATUS_DIFF_BIN diff added $FACTORY_OPKG_STATUS_FILE $USER_OPKG_STATUS_FILE > $OPKG_STATUS_PATCHES_DIR/packages-added.patch
if [ $? -ne 0 ]; then
    log $PREFIX "Failed to diff opkg status files ($OPKG_STATUS_DIFF_BIN diff added)"
    exit 1
fi

$OPKG_STATUS_DIFF_BIN diff removed $FACTORY_OPKG_STATUS_FILE $USER_OPKG_STATUS_FILE > $OPKG_STATUS_PATCHES_DIR/packages-removed.patch
if [ $? -ne 0 ]; then
    log $PREFIX "Failed to diff opkg status files ($OPKG_STATUS_DIFF_BIN diff removed)"
    rm -f added.txt
    exit 1
fi

log $PREFIX "OPKG status migration patches computed successfully"
exit 0

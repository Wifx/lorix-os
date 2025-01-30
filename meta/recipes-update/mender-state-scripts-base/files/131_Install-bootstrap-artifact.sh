#!/bin/sh

PREFIX=INSTALL-BOOTSTRAP-ARTIFACT
error=false

UBIDATA_MOUNT_PATH=/mnt/ubidata

source /data/mender/upgrade/migration-env.sh

# Mount ubidata volume

log $PREFIX "Mounting ubidata volume on $UBIDATA_MOUNT_PATH"

mkdir -p $UBIDATA_MOUNT_PATH
mount -t ubifs ubi0:data $UBIDATA_MOUNT_PATH

# Copy bootstrap artifact
MENDER_BOOTSTRAP_DIR=$UBIDATA_MOUNT_PATH/mender-bootstrap/$PARTITION_INACTIVE

mkdir -p $MENDER_BOOTSTRAP_DIR
rm -f $MENDER_BOOTSTRAP_DIR/*

cp /tmp/mender/bootstrap-artifact/bootstrap.mender $MENDER_BOOTSTRAP_DIR
if [ $? -ne 0 ]; then
    log $PREFIX "Failed to copy bootstrap artifact to $MENDER_BOOTSTRAP_DIR"
    error=true
else
    log $PREFIX "Copied bootstrap artifact to $MENDER_BOOTSTRAP_DIR"
fi

# Cleanup
rm -rf /tmp/mender/bootstrap-artifact
umount $UBIDATA_MOUNT_PATH
rm -rf $UBIDATA_MOUNT_PATH

if [ "$error" = true ]; then
    exit 1
fi

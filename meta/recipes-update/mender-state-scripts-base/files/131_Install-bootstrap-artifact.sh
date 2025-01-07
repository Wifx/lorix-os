#!/bin/sh

PREFIX=INSTALL-BOOTSTRAP-ARTIFACT
error=false

UBIDATA_MOUNT_PATH=/var/lib/migration/ubidata

source /data/mender/upgrade/migration-env.sh || exit 1

# Mount ubidata volume

echo "$PREFIX: Mounting ubidata volume on $UBIDATA_MOUNT_PATH"

mkdir -p $UBIDATA_MOUNT_PATH
mount -t ubifs ubi0:data $UBIDATA_MOUNT_PATH

# Copy bootstrap artifact
BOOTSTRAP_ARTIFACT_PATH=$UBIDATA_MOUNT_PATH/boostrap-artifact/$PARTITION_INACTIVE

mkdir -p $BOOTSTRAP_ARTIFACT_PATH
rm -f $BOOTSTRAP_ARTIFACT_PATH/*

cp /tmp/mender/bootstrap-artifact/bootstrap.mender $BOOTSTRAP_ARTIFACT_PATH
if [ $? -ne 0 ]; then
    echo "$PREFIX: Failed to copy bootstrap artifact to $BOOTSTRAP_ARTIFACT_PATH"
    error=true
else
    echo "$PREFIX: Copied bootstrap artifact to $BOOTSTRAP_ARTIFACT_PATH"
fi

# Cleanup
rm -rf /tmp/bootstrap-artifact
umount $UBIDATA_MOUNT_PATH
rm -rf $UBIDATA_MOUNT_PATH

if [ "$error" = true ]; then
    exit 1
fi

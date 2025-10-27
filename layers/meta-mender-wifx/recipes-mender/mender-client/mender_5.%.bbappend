# Copyright (c) 2022, Wifx Sarl <info@iot.wifx.net>
# All rights reserved.

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:append = " \
    file://0001-configurable-root-device.patch \
    file://0002-force-ubiupdatevol-use.patch \
"

DEFAULT_PREFERENCE = "0"

RDEPENDS:mender-update:append = " boost-log"

pkg_postinst_ontarget:${PN}() {

    error=false

    UBIDATA_MOUNT_PATH="/mnt/ubidata"
    MENDER_BOOTSTRAP_SOURCE_DIR="$UBIDATA_MOUNT_PATH/mender-bootstrap"
    MENDER_DATA_PATH="/data/mender"
    MENDER_BOOTSTRAP_TARGET_PATH="$MENDER_DATA_PATH/bootstrap.mender"

    # TODO: CMR check why this is now required
    mkdir -p $MENDER_DATA_PATH

    if [ -f $MENDER_DATA_PATH/mender-store ]; then
        echo "Mender store already exists at $MENDER_DATA_PATH/mender-store, skipping bootstrap artifact copy"
        exit 0
    fi

    if [ -f $MENDER_BOOTSTRAP_TARGET_PATH ]; then
        echo "Mender bootstrap artifact already exists on $MENDER_BOOTSTRAP_TARGET_PATH, skipping bootstrap artifact copy"
        exit 0
    fi

    # Find active and inactive partitions
    MOUNT=$(mount)
    PATTERN="overlay:config on \/etc.*upperdir=(rootfs[AB])"

    if [[ $MOUNT =~ $PATTERN ]]; then
        ROOTFS_MATCH=${BASH_REMATCH[1]}

        if [ "$ROOTFS_MATCH" == "rootfsA" ]; then
            ROOTFS_ACTIVE=A
            ROOTFS_INACTIVE=B
        elif [ "$ROOTFS_MATCH" == "rootfsB" ]; then
            ROOTFS_ACTIVE=B
            ROOTFS_INACTIVE=A
        fi
    fi

    # Mount mender artifact directory
    mkdir -p $UBIDATA_MOUNT_PATH
    mount -t ubifs ubi0:data $UBIDATA_MOUNT_PATH
    if [ $? -ne 0 ]; then
        echo "Failed to mount ubidata partition on $UBIDATA_MOUNT_PATH"
        rmdir $UBIDATA_MOUNT_PATH
        exit 1
    fi

    MENDER_BOOTSTRAP_SOURCE_PATH="$MENDER_BOOTSTRAP_SOURCE_DIR/$ROOTFS_ACTIVE/bootstrap.mender"

    if [ -f $MENDER_BOOTSTRAP_SOURCE_PATH ]; then

        # Copy mender bootstrap artifact
        cp $MENDER_BOOTSTRAP_SOURCE_PATH $MENDER_BOOTSTRAP_TARGET_PATH
        if [ $? -ne 0 ]; then
            echo "Failed to copy $MENDER_BOOTSTRAP_SOURCE_PATH to $MENDER_BOOTSTRAP_TARGET_PATH"
            error=true
        else
            echo "Mender bootstrap artifact copied to $MENDER_BOOTSTRAP_TARGET_PATH"
        fi
    fi

    # Cleanup
    umount $UBIDATA_MOUNT_PATH
    rmdir $UBIDATA_MOUNT_PATH

    if [ "$error" == "true" ]; then
        exit 1
    fi
}

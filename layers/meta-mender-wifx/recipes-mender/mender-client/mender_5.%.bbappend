# Copyright (c) 2022, Wifx Sarl <info@iot.wifx.net>
# All rights reserved.

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:append = " \
    file://0001-configurable-root-device.patch \
    file://0002-force-ubiupdatevol-use.patch \
"


pkg_postinst_ontarget:${PN}() {

    UBIDATA_MOUNT_PATH="/mnt/ubidata"
    MENDER_BOOTSTRAP_PATH="/data/mender/mender-bootstrap"
    MENDER_DATA_PATH="/data/mender"

    if [ -f $MENDER_DATA_PATH/mender-store ]; then
        echo "Mender store already exists at $MENDER_DATA_PATH/mender-store, skipping bootstrap artifact copy"
        exit 0
    fi

    if [ -f $MENDER_DATA_PATH/bootstrap.mender ]; then
        echo "Mender bootstrap artifact already exists on $MENDER_DATA_PATH/bootstrap.mender, skipping bootstrap artifact copy"
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

    mkdir -p $MENDER_BOOTSTRAP_PATH
    mount --bind $UBIDATA_MOUNT_PATH/mender-bootstrap/$ROOTFS_ACTIVE $MENDER_BOOTSTRAP_PATH
    if [ $? -ne 0 ]; then
        echo "Failed to mount $UBIDATA_MOUNT_PATH/mender-bootstrap/$ROOTFS_ACTIVE on $MENDER_BOOTSTRAP_PATH"
        rmdir $MENDER_BOOTSTRAP_PATH
        umount $UBIDATA_MOUNT_PATH
        rmdir $UBIDATA_MOUNT_PATH
        exit 1
    fi


    if [ -f $MENDER_BOOTSTRAP_PATH/bootstrap.mender ]; then

        # Copy mender bootstrap artifact
        cp $MENDER_BOOTSTRAP_PATH/bootstrap.mender $MENDER_DATA_PATH/bootstrap.mender
        if [ $? -ne 0 ]; then
            echo "Failed to copy $MENDER_BOOTSTRAP_PATH/bootstrap.mender to $MENDER_DATA_PATH/bootstrap.mender"
            exit 1
        fi

        echo "Mender bootstrap artifact copied to $MENDER_DATA_PATH/bootstrap.mender"
    fi

    # Cleanup
    umount $MENDER_BOOTSTRAP_PATH
    rmdir $MENDER_BOOTSTRAP_PATH

    umount $UBIDATA_MOUNT_PATH
    rmdir $UBIDATA_MOUNT_PATH
}

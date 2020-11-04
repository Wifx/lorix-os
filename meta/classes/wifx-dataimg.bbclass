# Copyright (c) 2019-2020, Wifx Sàrl <info@wifx.net>
# All rights reserved.

# Class to create the "dataimg" type, which contains the data partition as a raw
# filesystem.

IMAGE_TYPES += " dataimg"

IMAGE_CMD_dataimg() {
    if [ ! -d "${IMAGE_ROOTFS}/data" ]; then
        mkdir -p "${WORKDIR}/data"
        mkfs.ubifs -o "${WORKDIR}/data.ubifs" -r "${WORKDIR}/data" ${MKUBIFS_ARGS}
        rmdir "${WORKDIR}/data"
    else
        mkfs.ubifs -o "${WORKDIR}/data.ubifs" -r "${IMAGE_ROOTFS}/data" ${MKUBIFS_ARGS}
    fi

    install -m 0644 "${WORKDIR}/data.ubifs" "${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.dataimg"
}

# We need the data contents intact.
do_image_dataimg[respect_exclude_path] = "0"

do_image_dataimg[depends] += " mtd-utils-native:do_populate_sysroot"

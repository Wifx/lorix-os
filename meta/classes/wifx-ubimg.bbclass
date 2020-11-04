# Copyright (c) 2019-2020, Wifx Sàrl <info@wifx.net>
# All rights reserved.

# Class used to create an UBI image for Wifx products

# The UBI volume scheme is:
#    ubi0: rootfs read-only partition
#    ubi1: overlay data partition

inherit image
inherit image_types

IMAGE_TYPES += " ubimg"

do_image_ubimg[depends] += "mtd-utils-native:do_populate_sysroot"

IMAGE_CMD_ubimg () {
    # Added prompt error message for ubi and ubifs image creation.
    if [ -z "${MKUBIFS_ARGS}"] || [ -z "${UBINIZE_ARGS}" ]; then
        bbfatal "MKUBIFS_ARGS and UBINIZE_ARGS have to be set, see http://www.linux-mtd.infradead.org/faq/ubifs.html for details"
    fi

    if [ -z "${UBI_ROOTFS_SIZE_MB}"]; then
        bbfatal "UBI_ROOTFS_SIZE_MB has to be set in machine configuration file"
    fi

    mkdir -p "${WORKDIR}"

    # Workaround for the fact that the image builder requires this directory,
    # despite not using it. If "rm_work" is enabled, this directory won't always
    # exist.
    mkdir -p "${IMAGE_ROOTFS}"

    cat > ${WORKDIR}/ubimg-${IMAGE_NAME}.cfg <<EOF
[rootfs]
mode=ubi
image=${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.ubifs
vol_id=0
vol_size=${UBI_ROOTFS_SIZE_MB}MiB
vol_type=dynamic
vol_name=rootfs

[data]
mode=ubi
image=${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.dataimg
vol_id=1
vol_type=dynamic
vol_name=data
vol_flags=autoresize

EOF

    cat ${WORKDIR}/ubimg-${IMAGE_NAME}.cfg

    # ubinize ubifs volumes
    ubinize -o ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.ubimg ${UBINIZE_ARGS} ${WORKDIR}/ubimg-${IMAGE_NAME}.cfg

    # Cleanup cfg file
    mv ${WORKDIR}/ubimg-${IMAGE_NAME}.cfg ${IMGDEPLOYDIR}/

}

IMAGE_TYPEDEP_ubimg_append = " ubifs dataimg"

IMAGE_TYPEDEP_mender_append = " ${ARTIFACTIMG_FSTYPE}"

# So that we can use the files from excluded paths in the full images.
do_image_ubimg[respect_exclude_path] = "0"
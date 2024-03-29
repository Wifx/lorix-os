# Copyright (c) 2022, Wifx Sarl <info@iot.wifx.net>
# Based on meta-mender-core

# Class that creates an UBI image with an Mender layout

# The UBI volume scheme is:
#    ubi0: first rootfs, active
#    ubi1: second rootfs, inactive, mirror of first,
#           available as failsafe for when some update fails
#    ubi2: persistent data partition


inherit image
inherit image_types

do_image_ubimg[depends] += "mtd-utils-native:do_populate_sysroot"

IMAGE_CMD_ubimg () {
    set -e -x

    # For some reason, logging is not working correctly inside IMAGE_CMD bodies,
    # so wrap all logging in these functions that also have an echo. This won't
    # prevent warnings from being hidden deep in log files, but there is nothing
    # we can do about that.
    ubimg_warning() {
        echo "$@"
        bbwarn "$@"
    }
    ubimg_fatal() {
        echo "$@"
        bbfatal "$@"
    }

    mkdir -p "${WORKDIR}"

    # Workaround for the fact that the image builder requires this directory,
    # despite not using it. If "rm_work" is enabled, this directory won't always
    # exist.
    mkdir -p "${IMAGE_ROOTFS}"

    if [ "${MENDER_BOOT_PART_SIZE_MB}" != "0" ]; then
        ubimg_fatal "Boot partition is not supported for ubimg. MENDER_BOOT_PART_SIZE_MB should be set to 0."
    fi

    cat > ${WORKDIR}/ubimg-${IMAGE_NAME}.cfg <<EOF
[rootfsA]
mode=ubi
image=${IMGDEPLOYDIR}/${IMAGE_BASENAME}-${MACHINE}.ubifs
vol_id=0
vol_size=${MENDER_CALC_ROOTFS_SIZE}KiB
vol_type=dynamic
vol_name=rootfsa

[rootfsB]
mode=ubi
image=${IMGDEPLOYDIR}/${IMAGE_NAME}.emptyimg
vol_id=1
vol_size=${MENDER_CALC_ROOTFS_SIZE}KiB
vol_type=dynamic
vol_name=rootfsb

[data]
mode=ubi
image=${IMGDEPLOYDIR}/${IMAGE_NAME}.dataimg
vol_id=2
vol_size=${MENDER_DATA_PART_SIZE_MB}MiB
vol_type=dynamic
vol_name=data

EOF

    cat ${WORKDIR}/ubimg-${IMAGE_NAME}.cfg

    # ubinize ubifs volumes
    ubinize -o ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.ubimg ${UBINIZE_ARGS} ${WORKDIR}/ubimg-${IMAGE_NAME}.cfg

    # Cleanup cfg file
    mv ${WORKDIR}/ubimg-${IMAGE_NAME}.cfg ${IMGDEPLOYDIR}/

}

IMAGE_TYPEDEP_ubimg_append = " ubifs emptyimg dataimg"

# So that we can use the files from excluded paths in the full images.
do_image_ubimg[respect_exclude_path] = "0"
# Class to create the "dataimg" type, which contains the data partition as a raw
# filesystem.

IMAGE_CMD_emptyimg() {
    mkdir -p "${WORKDIR}/emptyimg"
    mkfs.ubifs -o "${WORKDIR}/emptyimg.ubifs" -r "${WORKDIR}/emptyimg" ${MKUBIFS_ARGS}
    rmdir "${WORKDIR}/emptyimg"
    install -m 0644 "${WORKDIR}/emptyimg.ubifs" "${IMGDEPLOYDIR}/${IMAGE_NAME}.emptyimg"
}

do_image_emptyimg[depends] += "${@bb.utils.contains('DISTRO_FEATURES', 'mender-image-ubi', 'mtd-utils-native:do_populate_sysroot', '', d)}"

# Class to create the "dataimg" type, which contains the data partition as a raw
# filesystem.

inherit wifx-mender-bootstrap

UBIDATA_DEPLOY_DIR = "${WORKDIR}/ubidata"

fakeroot do_setup_deploy_dir() {
    install -d "${UBIDATA_DEPLOY_DIR}"
}

IMAGE_CMD:dataimg:mender-image-ubi() {
    mkfs.ubifs -o "${WORKDIR}/data.ubifs" -r "${UBIDATA_DEPLOY_DIR}" ${MKUBIFS_ARGS}
    chmod 0644 "${WORKDIR}/data.ubifs"
    mv "${WORKDIR}/data.ubifs" "${IMGDEPLOYDIR}/${IMAGE_NAME}.dataimg"
}

do_image_dataimg[depends] += "${@bb.utils.contains('MENDER_FEATURES', 'mender-image-ubi', 'mtd-utils-native:do_populate_sysroot', '', d)}"

do_image_dataimg[prefuncs] += " do_setup_deploy_dir do_mender_bootstrap"

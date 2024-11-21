# Copyright (c) 2022, Wifx Sarl <info@iot.wifx.net>
# All rights reserved.

# We basically configure the build with full UBI feature of Mender
inherit mender-full-ubi

# Make mender feature globally visible
DISTRO_FEATURES:append = " mender"

# systemd is not desired as we use OpenRC
MENDER_FEATURES_DISABLE:append = " \
    mender-systemd \
"

# We don't need mtdimg which generates error related to empty partitions
IMAGE_FSTYPES:remove = "mtdimg"

# Disable image from meta-mender (replaced by ours)
IMAGE_CLASSES:remove = "mender-ubimg mender-dataimg"
IMAGE_CLASSES:append = " wifx-mender-ubimg wifx-emptyimg wifx-dataimg"

# This meta automatically use u-boot-fs-utils from Mender which is more 
# convenient (u-boot-fw-utils usage is highly tigh to atomic OTA update)
PREFERRED_PROVIDER_u-boot-fw-utils = "u-boot-fw-utils-mender-auto-provided"

# We do not want Mender to manager fstab for us, data partition is already
# managed in preinit script.
ROOTFS_POSTPROCESS_COMMAND:remove = "mender_update_fstab_file;"

# Create link to mender artifact in release deploy directory
IMAGE_POSTPROCESS_COMMAND += "final_deploy_link_mender_artifact ;"
final_deploy_link_mender_artifact() {
    mkdir -p ${IMGDEPLOYDIR}/release
    rm -rf ${IMGDEPLOYDIR}/release/*.mender
    ln -sr ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.mender ${IMGDEPLOYDIR}/release/${MENDER_ARTIFACT_NAME}_${MACHINE}.mender
}

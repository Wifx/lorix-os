# Copyright (c) 2022, Wifx Sarl <info@iot.wifx.net>
# All rights reserved.

# We basically configure the build with full UBI feature of Mender
inherit mender-full-ubi

# systemd is not desired as we use OpenRC
MENDER_FEATURES_DISABLE_append = " \
    mender-systemd \
"

# We don't need mtdimg which generates error related to empty partitions
IMAGE_FSTYPES_remove = "mtdimg"

# Disable image from meta-mender (replaced by ours)
IMAGE_CLASSES_remove = "mender-ubimg"
IMAGE_CLASSES += "wifx-mender-emptyimg wifx-mender-ubimg"

# This meta automatically use u-boot-fs-utils from Mender which is more 
# convenient (u-boot-fw-utils usage is highly tigh to atomic OTA update)
PREFERRED_PROVIDER_u-boot-fw-utils = "u-boot-fw-utils-mender-auto-provided"

# We do not want Mender to manager fstab for us, data partition is already
# managed in preinit script.
ROOTFS_POSTPROCESS_COMMAND_remove += "mender_update_fstab_file;"

# Create link to mender artifact in release deploy directory
IMAGE_POSTPROCESS_COMMAND += "final_deploy_link_mender_artifact ;"
final_deploy_link_mender_artifact() {
    rm -rf ${IMGDEPLOYDIR}/release/*.mender
    ln -sr ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.mender ${IMGDEPLOYDIR}/release/${MENDER_ARTIFACT_NAME}_${MACHINE}.mender
}

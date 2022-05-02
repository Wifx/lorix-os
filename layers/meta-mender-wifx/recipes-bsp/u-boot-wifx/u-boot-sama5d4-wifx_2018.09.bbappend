# Keep this separately from the rest of the .bb file in case that .bb file is
# overridden from another layer.

FILESEXTRAPATHS_prepend := "${THISDIR}/files/v2018.09-wifx:"

SRC_URI += " \
    file://0004-Add-common-mender-support.patch \
    file://0005-Add-mender-support-for-lorix-one-256-512-machines.patch \
    file://0005-Add-mender-support-for-the-L1-machine.patch \
"

MENDER_UBOOT_AUTO_CONFIGURE = "0"

require u-boot-mender.inc

# Copyright (c) 2022, Wifx SA <info@iot.wifx.net>
# All rights reserved.

FILESEXTRAPATHS:prepend := "${THISDIR}/files:${THISDIR}/files/v2022.01-at91:"

# The generic patch from Mender generates a warning. We replace it by our own
# which patches exactly the same things without warning.
SRC_URI:remove:mender-uboot = " \
    file://0002-Integration-of-Mender-boot-code-into-U-Boot.patch \
"

SRC_URI:append:mender-uboot = " \
    file://envs-mender/ \
    file://0001-Integration-of-Mender-boot-code-into-AT91-U-Boot.patch \
    file://0002-Add-mender-support-for-the-LORIX-One-machine.patch \
    file://0003-Add-mender-support-for-the-Wifx-L1-machine.patch \
"

ENV_FILEPATH:mender-uboot = "${WORKDIR}/envs-mender"

MENDER_UBOOT_AUTO_CONFIGURE = "0"

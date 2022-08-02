# Copyright (c) 2022, Wifx Sarl <info@iot.wifx.net>
# All rights reserved.

PV = "v2022.01-at91"

FILESEXTRAPATHS_prepend := "${THISDIR}/files/${PV}:"

SRC_URI += " \
    file://0001-Add-base-support-for-Wifx-LORIX-One-machine.patch \
    file://0002-Add-base-support-for-Wifx-L1-machine.patch \
"

FILESEXTRAPATHS_prepend := "${THISDIR}/files/:"
ENV_FILENAME = "u-boot-env.bin"

COMPATIBLE_MACHINE = "sama5d4-wifx"

require u-boot-at91-common.inc

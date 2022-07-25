# Copyright (c) 2022, Wifx Sarl <info@iot.wifx.net>
# All rights reserved.

LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://Licenses/README;md5=30503fd321432fc713238f582193b78e"

SRCREV = "0ea13bc67eb917c387267d38bbf4732cfd53f2fe"
PV = "v2019.04-at91"

FILESEXTRAPATHS_prepend := "${THISDIR}/files/${PV}:"
SRC_URI += " \
    git://github.com/linux4sam/u-boot-at91.git;protocol=https;branch=${UBRANCH} \
    file://0001-Add-base-support-for-Wifx-LORIX-One-machine.patch \
    file://0002-Add-base-support-for-Wifx-L1-machine.patch \
"

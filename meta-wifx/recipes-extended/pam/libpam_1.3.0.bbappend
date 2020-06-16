# Copyright (c) 2019-2020, Wifx Sàrl <info@wifx.net>
# All rights reserved.

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

# Adds update-motd.d support for motd dynamic generation from Ubuntu work
SRC_URI_FEATURE_MOTD_DYNAMIC = " \
    file://0001-Applied-update-motd.d-patch-from-Ubuntu-for-dynamic-.patch \
    file://0002-Applied-motd-legal-notice-patch-from-Ubuntu-for-lega.patch \
    file://0003-Added-support-for-yocto-lsbsysinit-arg-is-not-suppor.patch \
"
SRC_URI += "${@bb.utils.contains('DISTRO_FEATURES','motd-dynamic','${SRC_URI_FEATURE_MOTD_DYNAMIC}','',d)}"

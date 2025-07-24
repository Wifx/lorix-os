# Copyright (c) 2019, Wifx Sàrl <info@wifx.net>
# All rights reserved.

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# Adds update-motd.d support for motd dynamic generation from Ubuntu work
SRC_URI_FEATURE_MOTD_DYNAMIC = " \
    file://0001-Provide-a-more-dynamic-MOTD-based-on-the-short-lived.patch \
    file://0002-Display-the-contents-of-etc-legal-as-part-of-the-MOT.patch \
"
SRC_URI += "${@bb.utils.contains('DISTRO_FEATURES','motd-dynamic','${SRC_URI_FEATURE_MOTD_DYNAMIC}','',d)}"

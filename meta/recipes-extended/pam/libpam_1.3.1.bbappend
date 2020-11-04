# Copyright (c) 2019-2020, Wifx Sàrl <info@wifx.net>
# All rights reserved.

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

# Adds update-motd.d support for motd dynamic generation from Ubuntu work
SRC_URI_FEATURE_MOTD_DYNAMIC = " \
    file://0001-update-motd-from-Ubuntu-libpam-sources.patch \
    file://0002-pam_motd-legal-notice-from-Ubuntu-libpam-sources.patch \
    file://0003-pam_motd-Export-MOTD_SHOWN-pam-after-showing-MOTD.patch \
    file://0004-pam_motd-Mention-setting-MOTD_SHOWN-pam-in-the-man-p.patch \
    file://0005-Return-only-PAM_IGNORE-or-error-from-pam_motd.patch \
    file://0006-Added-support-for-yocto-lsbsysinit-arg-is-not-suppor.patch \
"
SRC_URI += "${@bb.utils.contains('DISTRO_FEATURES','motd-dynamic','${SRC_URI_FEATURE_MOTD_DYNAMIC}','',d)}"

# Copyright (c) 2022, Wifx Sarl <info@iot.wifx.net>
# All rights reserved.

require at91bootstrap.inc

# Don't use git commit in package version
PV = "3.10.2"

FILESEXTRAPATHS_prepend := "${THISDIR}/at91bootstrap-${PV}:"

SRC_URI += " \
    file://0001-Change-revision-to-wifx.patch \
    file://0002-Add-base-support-for-Wifx-LORIX-One-machine.patch \
    file://0003-Add-base-support-for-Wifx-L1-machine.patch \
"

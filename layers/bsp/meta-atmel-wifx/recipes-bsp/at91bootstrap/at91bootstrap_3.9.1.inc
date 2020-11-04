# Copyright (c) 2019-2020, Wifx Sàrl <info@wifx.net>
# All rights reserved.

require at91bootstrap.inc

FILESEXTRAPATHS_prepend := "${THISDIR}/at91bootstrap-3.9.1:"

SRC_URI += " \
    file://0001-Change-revision-to-wifx.patch \
    file://0002-Add-LORIX-One-support.patch \
    "

# Don't use git commit in package version
PV = "3.9.1"

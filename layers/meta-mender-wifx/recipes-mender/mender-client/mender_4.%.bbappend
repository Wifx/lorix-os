# Copyright (c) 2022, Wifx SA <info@iot.wifx.net>
# All rights reserved.

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:append = " \
    file://0001-configurable-root-device.patch \
    file://0002-force-ubiupdatevol-use.patch \
"

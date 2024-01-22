# Copyright (c) 2022, Wifx Sarl <info@iot.wifx.net>
# All rights reserved.

require recipes-mender/mender-client/mender-client.inc

RPROVIDES:${PN} += "virtual/updater"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:append = " file://artifact-verify-key.pem"

UPX_COMPRESS_FILES:${PN} = "/usr/bin/mender"
inherit upx

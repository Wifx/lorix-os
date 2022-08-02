# Copyright (c) 2022, Wifx Sarl <info@iot.wifx.net>
# All rights reserved.

require recipes-mender/mender-client/mender-client.inc

RPROVIDES_${PN} += "virtual/updater"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI_append = " file://artifact-verify-key.pem"

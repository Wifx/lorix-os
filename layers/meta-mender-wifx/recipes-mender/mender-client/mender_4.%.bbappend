# Copyright (c) 2022, Wifx Sarl <info@iot.wifx.net>
# All rights reserved.

RDEPENDS:${PN} += "xdelta3 machine-info"

RPROVIDES:${PN} += "virtual/updater"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:append = " \
    file://artifact-verify-key.pem \
    file://0001-configurable-root-device.patch \
"

UPX_COMPRESS_FILES:${PN} = "/usr/bin/mender-update /usr/bin/mender-auth"
inherit upx

MENDER_SERVER_URL = "https://hosted.mender.io"

FILES:mender-update += "\
    ${datadir}/mender/inventory \
    ${datadir}/mender/inventory/mender-inventory-machine \
"

do_install:append() {
    install -m 755 -d ${D}/${datadir}/mender/inventory
    ln -s /usr/sbin/machine-info ${D}/${datadir}/mender/inventory/mender-inventory-machine
}

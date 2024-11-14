# Copyright (c) 2022, Wifx Sarl <info@iot.wifx.net>
# All rights reserved.

RDEPENDS:${PN} += "xdelta3 machine-info"

RPROVIDES:${PN} += "virtual/updater"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:append = " \
    file://artifact-verify-key.pem \
    file://wifx-binary-delta \
    file://0001-configurable-root-device.patch \
    file://0002-force-ubiupdatevol-use.patch \
"

UPX_COMPRESS_FILES:${PN} = "/usr/bin/mender-update /usr/bin/mender-auth"
inherit upx

MENDER_SERVER_URL = "https://hosted.mender.io"

FILES:mender-update += "\
    ${datadir}/mender/inventory \
    ${datadir}/mender/inventory/mender-inventory-machine \
    ${datadir}/mender/modules/v3 \
    ${datadir}/mender/modules/v3/wifx-binary-delta \
"

do_install:append() {
    install -m 755 -d ${D}/${datadir}/mender/inventory
    ln -s /usr/sbin/machine-info ${D}/${datadir}/mender/inventory/mender-inventory-machine

    install -m 755 -d ${D}/${datadir}/mender/modules/v3
    install -m 755 ${WORKDIR}/wifx-binary-delta ${D}/${datadir}/mender/modules/v3/wifx-binary-delta
}

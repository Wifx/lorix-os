# Copyright (c) 2022, Wifx Sarl <info@iot.wifx.net>
# All rights reserved.

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += " \
    file://usb-gadget.initd \
"

inherit openrc

RDEPENDS:${PN} += "machine-info"

OPENRC_SERVICE_${PN} = "usb-gadget"
OPENRC_RUNLEVEL_usb-gadget = "default"

do_install:append() {
    # Install OpenRC script
    openrc_install_script ${WORKDIR}/usb-gadget.initd
}

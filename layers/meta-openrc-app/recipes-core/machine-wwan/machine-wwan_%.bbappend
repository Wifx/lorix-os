# Copyright (c) 2024, Wifx Sarl <info@iot.wifx.net>
# All rights reserved.

FILESEXTRAPATHS:append := "${THISDIR}/files:"

SRC_URI += "file://cellular.initd"

inherit openrc

OPENRC_SERVICE:${PN} = "cellular"
OPENRC_RUNLEVEL:cellular = "boot"

do_install:append:l1() {
    # Install OpenRC script
    openrc_install_script ${WORKDIR}/cellular.initd
}

FILES:${PN} += " \
    ${OPENRC_INITDIR}/* \
"
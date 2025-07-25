# Copyright (c) 2024, Wifx Sarl <info@iot.wifx.net>
# All rights reserved.

FILESEXTRAPATHS:append := "${THISDIR}/files:"

SRC_URI += " \
    file://wwan.initd \
"

inherit openrc

OPENRC_SERVICES:${PN} = "wwan"
OPENRC_RUNLEVEL:wwan = "boot"

do_install:append:l1() {
    # Install OpenRC script
    openrc_install_initd ${WORKDIR}/wwan.initd
}

FILES:${PN} += " \
    ${OPENRC_INITDIR}/* \
"

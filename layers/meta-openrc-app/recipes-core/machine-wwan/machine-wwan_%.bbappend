# Copyright (c) 2024, Wifx SA <info@iot.wifx.net>
# All rights reserved.

FILESEXTRAPATHS:append := "${THISDIR}/files:"

SRC_URI += " \
    file://wwan.initd \
    file://wwan.confd \
"

inherit openrc

OPENRC_SERVICES:${PN} = "wwan"
OPENRC_RUNLEVEL:wwan = "boot"
OPENRC_AUTO_ENABLE = "enable"

do_install:append:l1() {
    # Install OpenRC conf script
    openrc_install_confd ${WORKDIR}/wwan.confd

    # Install OpenRC script
    openrc_install_initd ${WORKDIR}/wwan.initd
}

FILES:${PN} += " \
    ${OPENRC_INITDIR}/* \
    ${OPENRC_CONFDIR}/* \
"

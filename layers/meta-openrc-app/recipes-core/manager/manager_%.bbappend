# Copyright (c) 2019-2020, Wifx SA <info@wifx.net>
# All rights reserved.
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
    file://managerd.initd \
    file://managerd.confd \
"

inherit openrc

OPENRC_SERVICES:${PN} = "managerd"
OPENRC_RUNLEVEL:managerd = "default"
OPENRC_AUTO_ENABLE = "enable"

do_install:append() {
    # Install OpenRC conf script
    openrc_install_confd ${WORKDIR}/managerd.confd

    # Install OpenRC script
    openrc_install_initd ${WORKDIR}/managerd.initd
}

FILES:${PN} += " \
    ${OPENRC_INITDIR}/managerd \
    ${OPENRC_CONFDIR}/managerd \
"
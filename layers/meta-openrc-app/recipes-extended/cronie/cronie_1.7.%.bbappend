# Copyright (c) 2020, Wifx SA <info@wifx.net>
# All rights reserved.

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
    file://crond.initd \
    file://crond.confd \
"

inherit openrc

OPENRC_SERVICES:${PN} = "crond"
OPENRC_RUNLEVEL:crond = "default"
OPENRC_AUTO_ENABLE = "enable"

do_install:append() {
    # Install OpenRC conf script
    openrc_install_confd ${WORKDIR}/crond.confd
    rm -rf ${D}${sysconfdir}/sysconfig/crond
    rm -rf ${D}${sysconfdir}/sysconfig

    # Install OpenRC script
    openrc_install_initd ${WORKDIR}/crond.initd
}

FILES:${PN}:remove = "${sysconfdir}/sysconfig/crond"

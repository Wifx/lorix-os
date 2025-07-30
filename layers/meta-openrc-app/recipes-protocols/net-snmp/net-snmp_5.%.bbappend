# Copyright (c) 2019-2020, Wifx Sàrl <info@wifx.net>
# All rights reserved.

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
    file://snmpd.initd \
    file://snmpd.confd \
    file://snmptrapd.initd \
    file://snmptrapd.confd \
"

inherit openrc

OPENRC_PACKAGES = "${PN}-server-snmpd ${PN}-server-snmptrapd"
OPENRC_SERVICES:${PN}-server-snmpd = "snmpd"
OPENRC_SERVICES:${PN}-server-snmptrapd = "snmptrapd"
OPENRC_AUTO_ENABLE = "disabled"

do_install:append() {
    # Install OpenRC conf script
    openrc_install_confd ${WORKDIR}/snmpd.confd
    openrc_install_confd ${WORKDIR}/snmptrapd.confd

    # Install OpenRC script
    openrc_install_initd ${WORKDIR}/snmpd.initd
    openrc_install_initd ${WORKDIR}/snmptrapd.initd
}

FILES:${PN}-server-snmpd += " \
    ${OPENRC_INITDIR}/snmpd \
    ${OPENRC_CONFDIR}/snmpd \
"

FILES:${PN}-server-snmptrapd += " \
    ${OPENRC_INITDIR}/snmptrapd \
    ${OPENRC_CONFDIR}/snmptrapd \
"

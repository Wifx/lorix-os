# Copyright (c) 2019-2020, Wifx Sàrl <info@wifx.net>
# All rights reserved.

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
    file://snmpd.initd \
    file://snmpd.confd \
    file://snmptrapd.initd \
    file://snmptrapd.confd \
"

inherit openrc

OPENRC_PACKAGES = "${PN}-server-snmpd ${PN}-server-snmptrapd"
# Services not enabled by default
#OPENRC_SERVICE_${PN}-server-snmpd = "snmpd"
#OPENRC_SERVICE_${PN}-server-snmptrapd = "snmptrapd"
#OPENRC_RUNLEVEL_snmpd = "default"
#OPENRC_RUNLEVEL_snmptrapd = "default"

do_install_append() {
    # Install OpenRC conf script
    openrc_install_config ${WORKDIR}/snmpd.confd
    openrc_install_config ${WORKDIR}/snmptrapd.confd

    # Install OpenRC script
    openrc_install_script ${WORKDIR}/snmpd.initd
    openrc_install_script ${WORKDIR}/snmptrapd.initd
}

FILES_${PN}-server-snmpd += " \
    ${OPENRC_INITDIR}/snmpd \
    ${OPENRC_CONFDIR}/snmpd \
"

FILES_${PN}-server-snmptrapd += " \
    ${OPENRC_INITDIR}/snmptrapd \
    ${OPENRC_CONFDIR}/snmptrapd \
"

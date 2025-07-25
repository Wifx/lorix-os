# Copyright (c) 2021, Wifx Sàrl <info@wifx.net>
# All rights reserved.

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
    file://zabbix-agent.initd \
    file://zabbix-agent.confd \
"

inherit openrc

OPENRC_SERVICES:${PN} = "zabbix-agent"

do_install:append() {
    # Install OpenRC conf script
    openrc_install_confd ${WORKDIR}/zabbix-agent.confd

    # Install OpenRC script
    openrc_install_initd ${WORKDIR}/zabbix-agent.initd
}

FILES:${PN} += " \
    ${OPENRC_INITDIR}/zabbix-agent \
    ${OPENRC_CONFDIR}/zabbix-agent \
"

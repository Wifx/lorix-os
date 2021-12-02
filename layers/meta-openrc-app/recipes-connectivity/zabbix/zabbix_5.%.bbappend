# Copyright (c) 2021, Wifx Sàrl <info@wifx.net>
# All rights reserved.

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
    file://zabbix-agent.initd \
    file://zabbix-agent.confd \
"

inherit openrc

OPENRC_PACKAGES = "${PN}"

do_install_append() {
    # Install OpenRC conf script
    openrc_install_config ${WORKDIR}/zabbix-agent.confd

    # Install OpenRC script
    openrc_install_script ${WORKDIR}/zabbix-agent.initd
}

FILES_${PN} += " \
    ${OPENRC_INITDIR}/zabbix-agent \
    ${OPENRC_CONFDIR}/zabbix-agent \
"

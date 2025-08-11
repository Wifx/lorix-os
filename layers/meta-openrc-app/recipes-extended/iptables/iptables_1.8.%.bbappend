# Copyright (c) 2025, Wifx SA <info@iot.wifx.net>
# All rights reserved.

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
    file://iptables.initd \
    file://iptables.confd \
    file://ip6tables.confd \
"

inherit openrc

OPENRC_SERVICES:${PN} = "iptables ${@bb.utils.contains('DISTRO_FEATURES', 'ipv6', 'ip6tables', '', d)}"

OPENRC_RUNLEVEL:iptables = "default"
OPENRC_RUNLEVEL:ip6tables = "default"
OPENRC_AUTO_ENABLE = "enable"

do_install:append() {
    # Install OpenRC conf script
    openrc_install_confd ${WORKDIR}/iptables.confd

    # Install OpenRC script
    openrc_install_initd ${WORKDIR}/iptables.initd

    if ${@bb.utils.contains('DISTRO_FEATURES', 'ipv6', 'true', 'false', d)}; then
        # Install OpenRC conf script for IPv6
        openrc_install_confd ${WORKDIR}/ip6tables.confd

        # Install OpenRC script for IPv6
        cp -f ${WORKDIR}/iptables.initd ${WORKDIR}/ip6tables.initd
        openrc_install_initd ${WORKDIR}/ip6tables.initd
    fi
}

FILES:${PN} += " \
    ${OPENRC_INITDIR}/iptables \
    ${OPENRC_CONFDIR}/iptables \
    ${sysconfdir}/runlevels \
    ${@bb.utils.contains('DISTRO_FEATURES', 'ipv6', '${OPENRC_INITDIR}/ip6tables ${OPENRC_CONFDIR}/ip6tables', '', d)} \
"

CONFFILES:${PN} += " \
    ${OPENRC_CONFDIR}/iptables \
    ${@bb.utils.contains('DISTRO_FEATURES', 'ipv6', '${OPENRC_CONFDIR}/ip6tables', '', d)} \
"


# Copyright (c) 2020, Wifx Sàrl <info@wifx.net>
# All rights reserved.

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
    file://iptables.initd \
    file://iptables.confd \
    file://ip6tables.confd \
"

inherit openrc

OPENRC_SERVICE_${PN} = "iptables ${@bb.utils.contains('DISTRO_FEATURES', 'ipv6', 'ip6tables', '', d)}"
OPENRC_SERVICE_${PN}_remove = "${@bb.utils.contains('IMAGE_FEATURES', 'disable-firewall', ' iptables ip6tables', '', d)}"

OPENRC_RUNLEVEL_iptables = "default"
OPENRC_RUNLEVEL_ip6tables = "default"

do_install_append() {
    # Install OpenRC conf script
    openrc_install_config ${WORKDIR}/iptables.confd

    # Install OpenRC script
    openrc_install_script ${WORKDIR}/iptables.initd

    if ${@bb.utils.contains('DISTRO_FEATURES', 'ipv6', 'true', 'false', d)}; then
        # Install OpenRC conf script for IPv6
        openrc_install_config ${WORKDIR}/ip6tables.confd

        # Install OpenRC script for IPv6
        cp -f ${WORKDIR}/iptables.initd ${WORKDIR}/ip6tables.initd
        openrc_install_script ${WORKDIR}/ip6tables.initd
    fi
}

FILES_${PN} += " \
    ${OPENRC_INITDIR}/iptables \
    ${OPENRC_CONFDIR}/iptables \
    ${sysconfdir}/runlevels \
    ${@bb.utils.contains('DISTRO_FEATURES', 'ipv6', '${OPENRC_INITDIR}/ip6tables ${OPENRC_CONFDIR}/ip6tables', '', d)} \
"

# Copyright (c) 2022, Wifx Sarl <info@iot.wifx.net>
# All rights reserved.

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
    file://iptables_override.rules \
    file://ip6tables_override.rules \
"

IPTABLES_RULES_DIR ?= "${sysconfdir}/${BPN}"

do_install_append() {
    install -d ${D}${IPTABLES_RULES_DIR}
    install -m 0644 ${WORKDIR}/iptables_override.rules ${D}${IPTABLES_RULES_DIR}/iptables.rules

    if ${@bb.utils.contains('PACKAGECONFIG', 'ipv6', 'true', 'false', d)} ; then
        install -m 0644 ${WORKDIR}/ip6tables_override.rules ${D}${IPTABLES_RULES_DIR}/ip6tables.rules
    fi
}

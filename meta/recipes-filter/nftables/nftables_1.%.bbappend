# Copyright (c) 2025, Wifx SA <info@iot.wifx.net>
# All rights reserved.

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
    file://nftables_override.conf \
    file://http.conf \
    file://ssh.conf \
    file://ping.conf \
    file://snmp.conf \
"

PACKAGECONFIG:remove = "python"

NFTABLES_CONF_DIR ?= "${sysconfdir}/nftables"
NFTABLES_AVAILABLE_SET_DIR = "${NFTABLES_CONF_DIR}/available"
NFTABLES_ACTIVE_SET_DIR = "${NFTABLES_CONF_DIR}/conf.d"

do_install:append() {
    install -d ${D}${NFTABLES_CONF_DIR}
    install -m 0644 ${WORKDIR}/nftables_override.conf ${D}${NFTABLES_CONF_DIR}/nftables.conf
    install -m 0644 ${WORKDIR}/ping.conf ${D}${NFTABLES_CONF_DIR}/ping.conf

    install -d ${D}${NFTABLES_AVAILABLE_SET_DIR}
    install -m 0644 ${WORKDIR}/ssh.conf ${D}${NFTABLES_AVAILABLE_SET_DIR}/ssh.conf
    install -m 0644 ${WORKDIR}/http.conf ${D}${NFTABLES_AVAILABLE_SET_DIR}/http.conf
    install -m 0644 ${WORKDIR}/snmp.conf ${D}${NFTABLES_AVAILABLE_SET_DIR}/snmp.conf

    install -d ${D}${NFTABLES_ACTIVE_SET_DIR}
    ln -snf ${NFTABLES_AVAILABLE_SET_DIR}/ssh.conf ${D}${NFTABLES_ACTIVE_SET_DIR}/10-ssh.conf
    ln -snf ${NFTABLES_AVAILABLE_SET_DIR}/http.conf ${D}${NFTABLES_ACTIVE_SET_DIR}/20-http.conf
}

FILES_${PN} += "${NFTABLES_CONF_DIR}/*"
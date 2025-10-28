# Copyright (c) 2025, Wifx SA <info@iot.wifx.net>
# All rights reserved.

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
    file://nftables_override.conf \
"

PACKAGECONFIG:remove = "python"

NFTABLES_CONF_DIR ?= "${sysconfdir}/nftables"

do_install:append() {
    install -d ${D}${NFTABLES_CONF_DIR}
    install -m 0644 ${WORKDIR}/nftables_override.conf ${D}${NFTABLES_CONF_DIR}/nftables.conf
}

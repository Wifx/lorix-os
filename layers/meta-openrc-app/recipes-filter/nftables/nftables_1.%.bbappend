# Copyright (c) 2025, Wifx SA <info@iot.wifx.net>
# All rights reserved.

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
    file://nftables.initd \
    file://nftables.confd \
"

inherit openrc

# OpenRC service configuration
OPENRC_SERVICES:${PN} = "nftables"
OPENRC_RUNLEVEL:nftables = "default"
OPENRC_AUTO_ENABLE = "enable"

do_install:append() {
    # Install OpenRC init script
    openrc_install_initd ${WORKDIR}/nftables.initd
    
    # Install OpenRC configuration
    openrc_install_confd ${WORKDIR}/nftables.confd
}

FILES:${PN} += " \
    ${OPENRC_INITDIR}/nftables \
    ${OPENRC_CONFDIR}/nftables \
"

RDEPENDS:${PN} += "openrc"
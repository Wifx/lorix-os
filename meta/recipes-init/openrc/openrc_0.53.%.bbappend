# Copyright (c) 2025, Wifx SA <info@iot.wifx.net>
# All rights reserved.

# The volatiles init script from meta-openrc doesn't handle default
# files/directories/link creation.
# Our version does.
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
    file://volatiles \
    file://volatiles.confd \
"

do_install:append() {
    # Install system related volatile configuration file
    install -m 755 -d ${D}${sysconfdir}/default/volatiles
    install -m 644 ${WORKDIR}/volatiles ${D}${sysconfdir}/default/volatiles/00_system

    # Install volatiles configuration file
    install -m 644 ${WORKDIR}/volatiles.confd ${D}${OPENRC_CONFDIR}/volatiles
}

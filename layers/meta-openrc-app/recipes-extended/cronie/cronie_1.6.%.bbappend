# Copyright (c) 2020, Wifx Sàrl <info@wifx.net>
# All rights reserved.

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
    file://crond.initd \
    file://crond.confd \
"

inherit openrc

OPENRC_SERVICE_${PN} = "crond"
OPENRC_RUNLEVEL_crond = "default"

do_install:append() {
    # Install OpenRC conf script
    openrc_install_config ${WORKDIR}/crond.confd
    rm -rf ${D}${sysconfdir}/sysconfig/crond
    rm -rf ${D}${sysconfdir}/sysconfig

    # Install OpenRC script
    openrc_install_script ${WORKDIR}/crond.initd
}

FILES:${PN}:remove = "${sysconfdir}/sysconfig/crond"

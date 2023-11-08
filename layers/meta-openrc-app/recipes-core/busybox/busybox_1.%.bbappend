# Copyright (c) 2019-2020, Wifx Sàrl <info@wifx.net>
# All rights reserved.

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
    file://busybox-klogd.initd \
    file://busybox-klogd.confd \
    file://busybox-syslogd.initd \
    file://busybox-syslogd.confd \
    file://add-getty.cfg \
    file://remove-start-stop-daemon.cfg \
"

inherit openrc

OPENRC_PACKAGES = "${PN}-syslog"
OPENRC_SERVICE:${PN}-syslog = "busybox-klogd busybox-syslogd"
OPENRC_RUNLEVEL:busybox-syslogd = "default"
OPENRC_RUNLEVEL:busybox-klogd = "default"

do_install:append() {
    # Install OpenRC conf script
    openrc_install_config ${WORKDIR}/busybox-klogd.confd
    openrc_install_config ${WORKDIR}/busybox-syslogd.confd

    # Install OpenRC script
    openrc_install_script ${WORKDIR}/busybox-klogd.initd
    openrc_install_script ${WORKDIR}/busybox-syslogd.initd

    # Remove useless files
    rm -rf ${D}${sysconfdir}/syslog-startup.conf
    rm -rf ${D}${sysconfdir}/default/busybox-syslog
}

FILES:${PN}-syslog += " \
    ${OPENRC_CONFDIR}/* \
    ${OPENRC_INITDIR}/* \
"
FILES:${PN}-syslog:remove = " \
    ${sysconfdir}/syslog-startup.conf* \
    ${sysconfdir}/default/busybox-syslog \
"

RDEPENDS:${PN}-syslog:append = " ${@bb.utils.contains('DISTRO_FEATURES','openrc','openrc','',d)}"

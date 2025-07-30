FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
    file://syslog-ng.initd \
    file://syslog-ng.confd \
"

inherit openrc

OPENRC_SERVICES:${PN} = "syslog-ng"
OPENRC_RUNLEVEL:syslog-ng = "default"
OPENRC_AUTO_ENABLE = "enable"

do_install:append() {
    # Install OpenRC conf script
    openrc_install_confd ${WORKDIR}/syslog-ng.confd

    # Install OpenRC script
    openrc_install_initd ${WORKDIR}/syslog-ng.initd
}

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
    file://watchdog.initd \
    file://watchdog.confd \
"

inherit openrc

OPENRC_SERVICES:${PN} = "watchdog"
OPENRC_RUNLEVEL:watchdog = "default"
OPENRC_AUTO_ENABLE = "enable"

do_install:append() {
    # Install OpenRC conf script
    openrc_install_confd ${WORKDIR}/watchdog.confd

    # Install OpenRC script
    openrc_install_initd ${WORKDIR}/watchdog.initd
}

FILES:${PN} += " \
    ${OPENRC_INITDIR}/watchdog \
    ${OPENRC_CONFDIR}/watchdog \
"
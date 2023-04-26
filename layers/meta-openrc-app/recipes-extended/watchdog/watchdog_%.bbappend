FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
    file://watchdog.initd \
    file://watchdog.confd \
"

inherit openrc

OPENRC_SERVICE_${PN} = "watchdog"
OPENRC_RUNLEVEL_watchdog = "default"

do_install:append() {
    # Install OpenRC conf script
    openrc_install_config ${WORKDIR}/watchdog.confd

    # Install OpenRC script
    openrc_install_script ${WORKDIR}/watchdog.initd
}

FILES:${PN} += " \
    ${OPENRC_INITDIR}/watchdog \
    ${OPENRC_CONFDIR}/watchdog \
"
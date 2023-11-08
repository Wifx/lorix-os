FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
    file://syslog-ng.initd \
    file://syslog-ng.confd \
"

inherit openrc

OPENRC_SERVICE:${PN} = "syslog-ng"
OPENRC_RUNLEVEL:syslog-ng = "default"

do_install:append() {
    # Install OpenRC conf script
    openrc_install_config ${WORKDIR}/syslog-ng.confd

    # Install OpenRC script
    openrc_install_script ${WORKDIR}/syslog-ng.initd
}

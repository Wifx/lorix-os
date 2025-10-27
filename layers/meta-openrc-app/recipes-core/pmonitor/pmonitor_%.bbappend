FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += " \
    file://pmonitord.initd \
    file://pmonitord.confd \
"

inherit openrc

OPENRC_SERVICES:${PN} = "pmonitord"
OPENRC_RUNLEVEL:pmonitord = "default"
OPENRC_AUTO_ENABLE = "enable"

do_install:append() {
    # Install OpenRC conf script
    openrc_install_confd ${WORKDIR}/pmonitord.confd

    # Install OpenRC script
    openrc_install_initd ${WORKDIR}/pmonitord.initd
}

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += " \
    file://pmonitord.initd \
    file://pmonitord.confd \
    "

inherit openrc

OPENRC_SERVICE:${PN} = "pmonitord"
OPENRC_RUNLEVEL:pmonitord = "default"

do_install:append() {
    # Install OpenRC conf script
    openrc_install_config ${WORKDIR}/pmonitord.confd

    # Install OpenRC script
    openrc_install_script ${WORKDIR}/pmonitord.initd
}

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI += " \
    file://pmonitord.initd \
    file://pmonitord.confd \
    "

inherit openrc

OPENRC_SERVICE_${PN} = "pmonitord"
OPENRC_RUNLEVEL_pmonitord = "default"

do_install_append() {
    # Install OpenRC conf script
    openrc_install_config ${WORKDIR}/pmonitord.confd

    # Install OpenRC script
    openrc_install_script ${WORKDIR}/pmonitord.initd
}

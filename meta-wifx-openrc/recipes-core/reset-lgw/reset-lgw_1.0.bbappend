FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI += " \
    file://reset-lgw.initd \
    file://reset-lgw.confd \
"

inherit openrc

OPENRC_SERVICE_${PN} = "reset-lgw"
OPENRC_RUNLEVEL_reset-lgw = "sysinit"

do_install_append() {
    # Install OpenRC conf script
    openrc_install_config ${WORKDIR}/reset-lgw.confd

    # Install OpenRC script
    openrc_install_script ${WORKDIR}/reset-lgw.initd
}

FILES_${PN} += " \
    ${OPENRC_INITDIR}/reset-lgw \
    ${OPENRC_CONFDIR}/reset-lgw \
"

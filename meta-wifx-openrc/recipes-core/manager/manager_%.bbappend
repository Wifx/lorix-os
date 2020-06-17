
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
    file://managerd.initd \
    file://managerd.confd \
"

inherit openrc

OPENRC_SERVICE_${PN} = "managerd"
OPENRC_RUNLEVEL_managerd = "default"

do_install_append() {
    # Install OpenRC conf script
    openrc_install_config ${WORKDIR}/managerd.confd

    # Install OpenRC script
    openrc_install_script ${WORKDIR}/managerd.initd
}

FILES_${PN} += " \
    ${OPENRC_INITDIR}/managerd \
    ${OPENRC_CONFDIR}/managerd \
"
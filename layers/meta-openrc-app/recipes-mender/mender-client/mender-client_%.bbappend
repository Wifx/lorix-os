FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
    file://menderd.initd \
    file://menderd.confd \
"

inherit openrc
#OPENRC_SERVICE_${PN} = "menderd"
OPENRC_RUNLEVEL_menderd = "default"

do_install_append() {
    # Install OpenRC conf script
    openrc_install_config ${WORKDIR}/menderd.confd

    # Install OpenRC script
    openrc_install_script ${WORKDIR}/menderd.initd
}

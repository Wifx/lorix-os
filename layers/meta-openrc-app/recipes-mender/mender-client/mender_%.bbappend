FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
    file://menderd.initd \
    file://menderd.confd \
    file://mender-auth.initd \
    file://mender-auth.confd \
"

inherit openrc
OPENRC_SERVICE:${PN} = "menderd menderd-auth"
OPENRC_RUNLEVEL:menderd = "default"

OPENRC_RUNLEVEL:menderd-auth = "default"

do_install:append() {
    # Install OpenRC conf script
    openrc_install_config ${WORKDIR}/menderd.confd

    # Install OpenRC script
    openrc_install_script ${WORKDIR}/menderd.initd

    # Install OpenRC conf script
    openrc_install_config ${WORKDIR}/mender-auth.confd

    # Install OpenRC script
    openrc_install_script ${WORKDIR}/mender-auth.initd
}

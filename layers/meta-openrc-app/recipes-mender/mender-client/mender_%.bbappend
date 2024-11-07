FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
    file://menderd.initd \
    file://menderd.confd \
    file://mender-auth.initd \
    file://mender-auth.confd \
"

inherit openrc
OPENRC_PACKAGES:${PN} = "menderd mender-auth"

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

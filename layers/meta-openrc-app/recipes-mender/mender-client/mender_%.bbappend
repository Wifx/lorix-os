FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
    file://menderd.initd \
    file://menderd.confd \
    file://mender-auth.initd \
    file://mender-auth.confd \
"

inherit openrc
OPENRC_SERVICES:${PN} = "menderd mender-auth"
OPENRC_AUTO_ENABLE = "enable"

do_install:append() {
    # Install OpenRC conf script
    openrc_install_confd ${WORKDIR}/menderd.confd

    # Install OpenRC script
    openrc_install_initd ${WORKDIR}/menderd.initd

    # Install OpenRC conf script
    openrc_install_confd ${WORKDIR}/mender-auth.confd

    # Install OpenRC script
    openrc_install_initd ${WORKDIR}/mender-auth.initd
}

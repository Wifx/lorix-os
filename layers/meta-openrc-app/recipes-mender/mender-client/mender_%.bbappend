FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
    file://mender-update.initd \
    file://mender-update.confd \
    file://mender-auth.initd \
    file://mender-auth.confd \
"

inherit openrc
OPENRC_SERVICES:${PN} = "mender-auth mender-update"

do_install:append() {
    # Install OpenRC conf script
    openrc_install_confd ${WORKDIR}/mender-update.confd

    # Install OpenRC script
    openrc_install_initd ${WORKDIR}/mender-update.initd

    # Install OpenRC conf script
    openrc_install_confd ${WORKDIR}/mender-auth.confd

    # Install OpenRC script
    openrc_install_initd ${WORKDIR}/mender-auth.initd
}

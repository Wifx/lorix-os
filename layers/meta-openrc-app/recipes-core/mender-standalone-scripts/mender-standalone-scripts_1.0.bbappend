FILESEXTRAPATHS:append := "${THISDIR}/files:"

SRC_URI += " \
    file://mender-standalone-scripts.confd \
    file://mender-standalone-scripts.initd \
"

inherit openrc

OPENRC_SERVICES:${PN} = "mender-standalone-scripts"
OPENRC_RUNLEVEL:mender-standalone-scripts = "boot"

do_install:append() {
    # Install OpenRC conf script
    openrc_install_confd ${WORKDIR}/mender-standalone-scripts.confd

    # Install OpenRC script
    openrc_install_initd ${WORKDIR}/mender-standalone-scripts.initd
}

FILES:${PN} += " \
    ${OPENRC_CONFDIR}/mender-standalone-scripts.confd \
    ${OPENRC_INITDIR}/mender-standalone-scripts.initd \
"

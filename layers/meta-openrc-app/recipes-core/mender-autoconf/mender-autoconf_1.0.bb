FILESEXTRAPATHS:append := "${THISDIR}/files:"

LICENSE = "CLOSED"

SRC_URI += " \
    file://mender-autoconf.confd \
    file://mender-autoconf.initd \
"

inherit openrc

OPENRC_SERVICES:${PN} = "mender-autoconf"
OPENRC_RUNLEVEL:mender-autoconf = "boot"
OPENRC_AUTO_ENABLE = "enable"

do_install:append() {
    # Install OpenRC conf script
    openrc_install_confd ${WORKDIR}/mender-autoconf.confd

    # Install OpenRC script
    openrc_install_initd ${WORKDIR}/mender-autoconf.initd
}

FILES:${PN} += " \
    ${OPENRC_CONFDIR}/mender-autoconf.confd \
    ${OPENRC_INITDIR}/mender-autoconf.initd \
"

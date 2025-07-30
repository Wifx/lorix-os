FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://avahi-daemon.initd"

inherit openrc

RDEPENDS:${PN}-daemon:append = " openrc"
RDEPENDS:${PN}-dnsconfd:append = " openrc"

OPENRC_PACKAGES = "${PN}-daemon"
OPENRC_SERVICES:${PN}-daemon = "avahi-daemon"
OPENRC_RUNLEVEL:avahi-daemon = "default"
OPENRC_AUTO_ENABLE = "enable"

do_install:append() {
    # Install OpenRC script
    openrc_install_initd ${WORKDIR}/avahi-daemon.initd
}

FILES:avahi-daemon += " \
    ${OPENRC_INITDIR}/* \
    ${sysconfdir}/runlevels/* \
    "

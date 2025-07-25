FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://avahi-daemon.initd"

inherit openrc

RDEPENDS:avahi-daemon:append = " openrc"
RDEPENDS:avahi-dnsconfd:append = " openrc"

OPENRC_PACKAGES = "${PN}-daemon"
OPENRC_SERVICES:${PN}-daemon = "avahi-daemon"
OPENRC_RUNLEVEL:avahi-daemon = "default"

do_install:append() {
    # Install OpenRC script
    openrc_install_initd ${WORKDIR}/avahi-daemon.initd
}

FILES:avahi-daemon += " \
    ${OPENRC_INITDIR}/* \
    ${sysconfdir}/runlevels/* \
    "

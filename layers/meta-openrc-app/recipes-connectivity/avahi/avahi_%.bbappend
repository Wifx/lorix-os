FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://avahi-daemon.initd"

inherit openrc

RDEPENDS:avahi-daemon = "openrc"

OPENRC_PACKAGES = "${PN}-daemon"
OPENRC_SERVICE:${PN}-daemon = "avahi-daemon"
OPENRC_RUNLEVEL:avahi-daemon = "default"

do_install:append() {
    # Install OpenRC script
    openrc_install_script ${WORKDIR}/avahi-daemon.initd
}

FILES:avahi-daemon += " \
    ${OPENRC_INITDIR}/* \
    ${sysconfdir}/runlevels/* \
    "

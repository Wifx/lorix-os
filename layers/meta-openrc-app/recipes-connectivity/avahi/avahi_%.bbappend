FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://avahi-daemon.initd"

inherit openrc

RDEPENDS_avahi-daemon = "openrc"

OPENRC_PACKAGES = "${PN}-daemon"
OPENRC_SERVICE_${PN}-daemon = "avahi-daemon"
OPENRC_RUNLEVEL_avahi-daemon = "default"

do_install_append() {
    # Install OpenRC script
    openrc_install_script ${WORKDIR}/avahi-daemon.initd
}

FILES_avahi-daemon += " \
    ${OPENRC_INITDIR}/* \
    ${sysconfdir}/runlevels/* \
    "

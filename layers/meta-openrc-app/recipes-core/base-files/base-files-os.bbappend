FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
    file://firstboot.initd \
    file://stopstatusled.initd \
    "

inherit openrc

OPENRC_SERVICES:${PN} = "firstboot stopstatusled"
OPENRC_RUNLEVEL:firstboot = "default"
OPENRC_RUNLEVEL:stopstatusled = "shutdown"
OPENRC_AUTO_ENABLE = "enable"

do_install:append() {
    # Install OpenRC script
    openrc_install_initd ${WORKDIR}/firstboot.initd
    openrc_install_initd ${WORKDIR}/stopstatusled.initd
}

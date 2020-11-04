FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
    file://firstboot.initd \
    file://stopstatusled.initd \
    "

inherit openrc

OPENRC_SERVICE_${PN} = "firstboot stopstatusled"
OPENRC_RUNLEVEL_firstboot = "default"
OPENRC_RUNLEVEL_stopstatusled = "shutdown"

do_install_append() {
    # Install OpenRC script
    openrc_install_script ${WORKDIR}/firstboot.initd
    openrc_install_script ${WORKDIR}/stopstatusled.initd
}

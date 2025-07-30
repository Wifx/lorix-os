# Note: Despite being built via './configure; make; make install',
#       chrony does not use GNU Autotools.

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
    file://monit.initd \
"

inherit openrc

OPENRC_SERVICES:${PN} = "monit"
OPENRC_RUNLEVEL:monit = "default"
OPENRC_AUTO_ENABLE = "enable"

do_install:append() {
    # Install OpenRC script
    openrc_install_initd ${WORKDIR}/monit.initd
}

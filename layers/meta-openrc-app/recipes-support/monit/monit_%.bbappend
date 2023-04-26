# Note: Despite being built via './configure; make; make install',
#       chrony does not use GNU Autotools.

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
    file://monit.initd \
"

inherit openrc

OPENRC_SERVICE_${PN} = "monit"
OPENRC_RUNLEVEL_monit = "default"

do_install:append() {
    # Install OpenRC script
    openrc_install_script ${WORKDIR}/monit.initd
}

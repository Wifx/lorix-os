# Note: Despite being built via './configure; make; make install',
#       chrony does not use GNU Autotools.

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
    file://monit.initd \
"

inherit openrc

OPENRC_SERVICE_${PN} = "monit"
OPENRC_RUNLEVEL_monit = "default"

do_install_append() {
    # Install OpenRC script
    openrc_install_script ${WORKDIR}/monit.initd
}

# Note: Despite being built via './configure; make; make install',
#       chrony does not use GNU Autotools.

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
    file://chronyd.initd \
    file://chronyd.confd \
"

inherit openrc

OPENRC_SERVICE_${PN} = "chronyd"
OPENRC_RUNLEVEL_chronyd = "default"

do_install_append() {
    # Install OpenRC conf script
    openrc_install_config ${WORKDIR}/chronyd.confd

    # Install OpenRC script
    openrc_install_script ${WORKDIR}/chronyd.initd
}

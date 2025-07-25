# Note: Despite being built via './configure; make; make install',
#       chrony does not use GNU Autotools.

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
    file://chronyd.initd \
    file://chronyd.confd \
"

inherit openrc

OPENRC_SERVICES:${PN} = "chronyd"
OPENRC_RUNLEVEL:chronyd = "default"

do_install:append() {
    # Install OpenRC conf script
    openrc_install_confd ${WORKDIR}/chronyd.confd

    # Install OpenRC script
    openrc_install_initd ${WORKDIR}/chronyd.initd
}

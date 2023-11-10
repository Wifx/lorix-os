# Copyright (c) 2019-2020, Wifx Sàrl <info@wifx.net>
# All rights reserved.
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
    file://managerd.initd \
    file://managerd.confd \
"

inherit openrc

OPENRC_SERVICE:${PN} = "managerd"
OPENRC_RUNLEVEL:managerd = "default"

do_install:append() {
    # Install OpenRC conf script
    openrc_install_config ${WORKDIR}/managerd.confd

    # Install OpenRC script
    openrc_install_script ${WORKDIR}/managerd.initd
}

FILES:${PN} += " \
    ${OPENRC_INITDIR}/managerd \
    ${OPENRC_CONFDIR}/managerd \
"
SUMMARY = "Run mender opkg package configure on boot"
DESCRIPTION = "Mender daemon will be started at boot time and it must not be restarted during the update process. By running 'opkg configure' prio to running mender, we ensure that it is properly configured before starting and also that it will not get restarted during later 'opkg configure' executions."
AUTHOR = "Wifx SA"
SECTION = "base"

FILESEXTRAPATHS:append := "${THISDIR}/files:"

LICENSE = "CLOSED"

SRC_URI += " \
    file://mender-autoconf.confd \
    file://mender-autoconf.initd \
"

inherit openrc

OPENRC_SERVICES:${PN} = "mender-autoconf"
OPENRC_RUNLEVEL:mender-autoconf = "boot"
OPENRC_AUTO_ENABLE = "enable"

do_install:append() {
    # Install OpenRC conf script
    openrc_install_confd ${WORKDIR}/mender-autoconf.confd

    # Install OpenRC script
    openrc_install_initd ${WORKDIR}/mender-autoconf.initd
}

FILES:${PN} += " \
    ${OPENRC_CONFDIR}/mender-autoconf.confd \
    ${OPENRC_INITDIR}/mender-autoconf.initd \
"

SUMMARY = "Persistent logs service"
DESCRIPTION = "OpenRC service that saves system logs to persistent storage on shutdown and restores them on startup"
AUTHOR = "Wifx SA"
SECTION = "base"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=2f537ab2753263599e6e0f1d0ce9cfd3"

SRC_URI = " \
    file://LICENSE \
    file://persistent-logs.initd \
    file://persistent-logs.confd \
    file://persistent-logs.sh \
"

PR = "r0"
S = "${WORKDIR}"

INHIBIT_DEFAULT_DEPS = "1"
do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"

inherit openrc

OPENRC_SERVICE:${PN} = "persistent-logs"
OPENRC_RUNLEVEL:persistent-logs = "sysinit"
OPENRC_AUTO_ENABLE = "enable"

# Runtime dependencies
RDEPENDS:${PN} += "bash tar gzip findutils coreutils"

do_install() {
    # Install OpenRC configuration file
    openrc_install_confd ${WORKDIR}/persistent-logs.confd

    # Install OpenRC init script
    openrc_install_initd ${WORKDIR}/persistent-logs.initd
    
    # Install standalone persistent-logs management script
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/persistent-logs.sh ${D}${bindir}/persistent-logs
}

FILES:${PN} += " \
    ${OPENRC_CONFDIR}/persistent-logs \
    ${OPENRC_INITDIR}/persistent-logs \
    ${bindir}/persistent-logs \
"

SUMMARY = "Mender Rollback Timer"
DESCRIPTION = "Reboots the device if a Mender update is not committed within a timeout"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
    file://mender-rollback-timer.sh \
    file://mender-rollback-timer.initd \
    file://mender-rollback-timer.confd \
"

inherit openrc
OPENRC_SERVICES:${PN} = "mender-rollback-timer"
OPENRC_RUNLEVEL:managerd = "default"
OPENRC_AUTO_ENABLE = "enable"

RDEPENDS:${PN} += "u-boot-fw-utils"

do_install() {
    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/mender-rollback-timer.sh ${D}${sbindir}/mender-rollback-timer.sh

    # Install OpenRC conf script
    openrc_install_confd ${WORKDIR}/mender-rollback-timer.confd

    # Install OpenRC script
    openrc_install_initd ${WORKDIR}/mender-rollback-timer.initd
}

FILES:${PN} += " \
    ${sbindir}/mender-rollback-timer.sh \
    ${OPENRC_INITDIR}/mender-rollback-timer \
    ${OPENRC_CONFDIR}/mender-rollback-timer \
"

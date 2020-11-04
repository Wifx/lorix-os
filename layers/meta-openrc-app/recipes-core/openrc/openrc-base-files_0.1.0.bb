LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

S="${WORKDIR}"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
    file://volatiles.initd \
    file://volatiles.confd \
    file://volatiles \
    file://udev.initd \
    file://alignment.initd \
"

inherit openrc

OPENRC_SERVICE_${PN} = "volatiles udev alignment"
OPENRC_RUNLEVEL_volatiles = "boot"
OPENRC_RUNLEVEL_udev = "sysinit"
OPENRC_RUNLEVEL_alignment = "sysinit"

INHIBIT_DEFAULT_DEPS = "1"
do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    # Install OpenRC script config files
    openrc_install_config ${WORKDIR}/volatiles.confd
    install -m 0755 -d ${D}${sysconfdir}/default/volatiles
    install -m 0644 ${WORKDIR}/volatiles ${D}${sysconfdir}/default/volatiles/00_system
    # Install OpenRC scripts
    openrc_install_script ${WORKDIR}/volatiles.initd
    openrc_install_script ${WORKDIR}/udev.initd
    openrc_install_script ${WORKDIR}/alignment.initd
}

RDEPENDS_${PN} = "openrc"
PACKAGE_ARCH = "${MACHINE_ARCH}"

SUMMARY = "Basic scripts which manages the service LED"
AUTHOR = "Wifx SA"
SECTION = "base"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=ac08f2eed56d2f4b41ce86b963832f5c"

SRC_URI = " \
    file://LICENSE \
    file://led-service.initd \
"

PR = "r0"
S = "${WORKDIR}"

INHIBIT_DEFAULT_DEPS = "1"
do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"

inherit openrc

OPENRC_SERVICES:${PN} = "led-service"
OPENRC_RUNLEVEL:led-service = "default"
OPENRC_AUTO_ENABLE = "enable"

do_install:l1() {
    # Install OpenRC script
    openrc_install_initd ${WORKDIR}/led-service.initd
}

PACKAGE_ARCH = "${MACHINE_ARCH}"
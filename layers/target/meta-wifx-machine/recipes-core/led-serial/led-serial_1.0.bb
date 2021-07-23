SUMMARY = "Basic scripts which manages the serial LED"
AUTHOR = "Wifx Sàrl"
SECTION = "base"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=83564c4ad755d0edeaa1ba4b3918b365"

SRC_URI = " \
    file://LICENSE \
    file://led-serial.initd \
"

PR = "r0"
S = "${WORKDIR}"

INHIBIT_DEFAULT_DEPS = "1"
do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"

inherit openrc

OPENRC_SERVICE_${PN} = "led-serial"
OPENRC_RUNLEVEL_led-serial = "default"

do_install_l1() {
    # Install OpenRC script
    openrc_install_script ${WORKDIR}/led-serial.initd
}

PACKAGE_ARCH = "${MACHINE_ARCH}"
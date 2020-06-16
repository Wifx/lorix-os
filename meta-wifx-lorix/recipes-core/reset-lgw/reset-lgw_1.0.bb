SUMMARY = "Basic init scripts which manages the SX1301 reset pin"
DESCRIPTION = "This package provides the init script which manages the RESET pin of the SX1301 RF gateway chip"
AUTHOR = "Wifx Sàrl"
SECTION = "base"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=83564c4ad755d0edeaa1ba4b3918b365"

SRC_URI += " \
    file://LICENSE \
    file://init \
"

PR = "r0"
S = "${WORKDIR}"

inherit update-rc.d

INITSCRIPT_NAME = "reset-lgw"
INITSCRIPT_PARAMS = "start 01 2 3 4 5 . stop 81 0 1 6 ."

do_install () {
	install -d ${D}${sysconfdir}/init.d
	install -m 0755 ${WORKDIR}/init ${D}${sysconfdir}/init.d/${INITSCRIPT_NAME}
}

FILES_${PN} =+ "${sysconfdir}/init.d/${INITSCRIPT_NAME}"

SUMMARY = "Runs mender state scripts in standalone mode"
DESCRIPTION = "Provides a script to run mender state scripts in standalone mode"
AUTHOR = "Wifx SA"
SECTION = "base"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=ac08f2eed56d2f4b41ce86b963832f5c"

RDEPENDS:${PN} += "libubootenv mender"

SRC_URI += " \
    file://LICENSE \
    file://mender-standalone-scripts.sh \
"

PR = "r0"
S = "${WORKDIR}"

INITSCRIPT_NAME="mender-standalone-scripts"

inherit update-rc.d

do_install () {
	install -d ${D}${sbindir}
	install -m 0754 ${WORKDIR}/mender-standalone-scripts.sh ${D}${sbindir}/mender-standalone-scripts
}

FILES:${PN} =+ " \
    ${sbindir}/mender-standalone-scripts \
"

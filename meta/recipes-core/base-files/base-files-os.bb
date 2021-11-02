SUMMARY = "Miscellaneous files for the OS base system"
DESCRIPTION = "Provides the OS basic set of key configuration files for the system."
AUTHOR = "Wifx Sàrl"
SECTION = "base"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=1ded0c06942a7820da745e412d9aba9b"

SRC_URI = " \
    file://LICENSE \
    file://preinit \
    file://.functions \
    file://functions \
"

PR = "r0"
S = "${WORKDIR}"

INHIBIT_DEFAULT_DEPS = "1"
do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"

RDEPENDS_${PN} =+ " \
    machine-info \
    gawk \
    sed \
"

osdir = "${sysconfdir}/os"

do_install () {
    install -d -m 0755 ${D}${osdir}
    # Install general OS scripting tools file
    install -m 0644 ${WORKDIR}/.functions ${D}${osdir}/.functions
    install -m 0755 ${WORKDIR}/functions ${D}${osdir}/functions

    # Install base boot scripts
    install -m 0700 ${WORKDIR}/preinit ${D}${sysconfdir}/preinit

    # Prepare for the overlayfs and reserve this directory
    install -d -m 0755 ${D}/data/layers
}

FILES_${PN} += " \
    ${sysconfdir}/* \
    ${osdir}/* \
    /data/layers \
"

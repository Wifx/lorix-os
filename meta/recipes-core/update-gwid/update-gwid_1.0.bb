SUMMARY = "Semtech script to update packet-forwarder conf script gateway ID"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=8914a4e3e239f601f0ce33848abc519f"
PR = "r0"

SRC_URI = " \
    file://LICENSE \
    file://update-gwid.sh \
    "

INHIBIT_DEFAULT_DEPS = "1"
do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install () {
    install -m 0755 -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/update-gwid.sh ${D}${sbindir}/update-gwid
}

PACKAGE_ARCH = "${MACHINE_ARCH}"

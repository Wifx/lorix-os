SUMMARY = "TBD"
DESCRIPTION = "TBD"
AUTHOR = "Wifx Sarl"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=073bf747e205468f394819c786015ecc"

SRC_URI += " \
    file://LICENSE \
    file://serial.sh \
"

PR = "r0"
S = "${WORKDIR}"

INHIBIT_DEFAULT_DEPS = "1"
do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"

RPROVIDES_${PN} += "virtual/usb-gadget"
RDEPENDS_${PN} += " \
    kernel-module-libcomposite \
    kernel-module-usb-f-acm kernel-module-u-serial \
    kernel-module-g-serial \
"

do_install() {
    install -d -m 0755 ${D}${sysconfdir}/usb-gadget/scripts
    install -m 0744 ${WORKDIR}/serial.sh ${D}${sysconfdir}/usb-gadget/scripts
}

#KERNEL_MODULE_AUTOLOAD += "g_serial"

FILES_${PN} += " \
    ${sysconfdir}/usb-gadget/scripts/* \
"

RCONFLICTS_${PN} += "usb-gadget-serial-rndis"

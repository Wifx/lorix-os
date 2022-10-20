SUMMARY = "TBD"
DESCRIPTION = "TBD"
AUTHOR = "Wifx Sarl"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=073bf747e205468f394819c786015ecc"

SRC_URI += " \
    file://LICENSE \
    file://br-usb.nmconnection \
    file://usb0.nmconnection \
    file://usb0_2.nmconnection \
    file://dnsmasq-default \
    file://dnsmasq-bridge-usb.conf \
"

PR = "r0"
S = "${WORKDIR}"

INHIBIT_DEFAULT_DEPS = "1"
do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"

RPROVIDES_${PN} += "virtual/usb-gadget"
RDEPENDS_${PN} += "networkmanager"
RRECOMMENDS_${PN} += " \
    kernel-module-libcomposite \
    kernel-module-usb-f-acm kernel-module-u-serial \
    kernel-module-usb-f-rndis kernel-module-u-ether \
"

do_install() {
    # Add connection configuration for usb0
    install -d ${D}${sysconfdir}/NetworkManager/system-connections
    #install -m 0600 ${WORKDIR}/br-usb.nmconnection ${D}${sysconfdir}/NetworkManager/system-connections
    #install -m 0600 ${WORKDIR}/usb0.nmconnection ${D}${sysconfdir}/NetworkManager/system-connections
    install -m 0600 ${WORKDIR}/usb0_2.nmconnection ${D}${sysconfdir}/NetworkManager/system-connections/usb0.nmconnection

    # Add dnsmasq configurations
    install -d ${D}${sysconfdir}/default/volatiles
    install -m 0644 ${WORKDIR}/dnsmasq-default ${D}${sysconfdir}/default/volatiles/99_dnsmasq
    install -d ${D}${sysconfdir}/NetworkManager/dnsmasq.d
    install -d ${D}${sysconfdir}/dnsmasq.d
    install -m 0644 ${WORKDIR}/dnsmasq-bridge-usb.conf ${D}${sysconfdir}/dnsmasq.d/usb-dhcp.conf
}

PACKAGE_ARCH = "${MACHINE_ARCH}"
# This recipe need to define a valid VID for the USB gadget (UART + RNDIS)
# Ensure the compatibility between VID and existing machine.
# Do not replace by sama5d4-wifx to ensure error on new machine.
COMPATIBLE_MACHINE = "(lorix-one-256|lorix-one-512|l1)"

RCONFLICTS_${PN} += "usb-gadget-serial"


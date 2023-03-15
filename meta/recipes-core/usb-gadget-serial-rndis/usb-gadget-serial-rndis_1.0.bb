# Copyright (c) 2022, Wifx Sarl <info@iot.wifx.net>
# All rights reserved.
SUMMARY = "Ethernet + Serial over USB support for Wifx products"
AUTHOR = "Wifx Sarl"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=073bf747e205468f394819c786015ecc"

SRC_URI += " \
    file://LICENSE \
    file://usb.nmconnection \
    file://dnsmasq-default \
    file://dnsmasq-usb.conf \
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
    # Add usb connection configuration to manager usb0 device
    install -d ${D}${sysconfdir}/NetworkManager/system-connections
    install -m 0600 ${WORKDIR}/usb.nmconnection ${D}${sysconfdir}/NetworkManager/system-connections/usb.nmconnection

    # Add dnsmasq configurations
    install -d ${D}${sysconfdir}/default/volatiles
    install -m 0644 ${WORKDIR}/dnsmasq-default ${D}${sysconfdir}/default/volatiles/99_dnsmasq
    install -d ${D}${sysconfdir}/dnsmasq.d
    install -m 0644 ${WORKDIR}/dnsmasq-usb.conf ${D}${sysconfdir}/dnsmasq.d/usb-dhcp.conf
}

pkg_postinst_ontarget_${PN} () {
    # execute only on first boot
    # Update dhcp static IP attribution filter with USB host MAC address
    mac=$(cat /sys/class/net/eth0/address)
    addr_host=$(echo $mac | awk -F':' '{$1="12"; printf "%s:%s:%s:%s:%s:%s",$1,$2,$3,$4,$5,$6}')

    sed -i "s|#dhcp-host=@{USB_HOST_MAC},172.20.20.2|dhcp-host=${addr_host},172.20.20.2|" ${sysconfdir}/dnsmasq.d/usb-dhcp.conf
}

PACKAGE_ARCH = "${MACHINE_ARCH}"
# This recipe need to define a valid VID for the USB gadget (UART + RNDIS)
# Ensure the compatibility between VID and existing machine.
# Do not replace by sama5d4-wifx to ensure error on new machine.
COMPATIBLE_MACHINE = "(lorix-one-256|lorix-one-512|l1)"

RCONFLICTS_${PN} += "usb-gadget-serial"


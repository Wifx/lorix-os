# Copyright (c) 2025, Wifx SA <info@iot.wifx.net>
# All rights reserved.

PACKAGECONFIG = "dhcp dbus loop"
# dhcp is required for "Ethernet over USB"'s DHCP server
# dbus is required for NetworkManager integration
# loop protects against DNS loop

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://10-use-dnsmasq.conf"

do_install:append() {
    # Install default configuration files for the NetworkManager
    install -d ${D}${sysconfdir}/NetworkManager/conf.d
    install -m 0644 ${WORKDIR}/10-use-dnsmasq.conf ${D}${sysconfdir}/NetworkManager/conf.d/10-use-dnsmasq.conf
}

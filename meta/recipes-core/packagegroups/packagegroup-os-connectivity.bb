# Copyright (c) 2019-2020, Wifx Sàrl <info@wifx.net>
# All rights reserved.

SUMMARY = "OS Connectivity Package Group"
LICENSE = "Apache-2.0"

PR = "r0"

#
# packages which content depend on MACHINE_FEATURES need to be MACHINE_ARCH
#
PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

# By default, the OS uses networkmanager
NETWORK_MANAGER_PACKAGES ?= "networkmanager networkmanager-openvpn "

CONNECTIVITY_MODULES = ""

CONNECTIVITY_WIRELESS_FIRMWARES ?= " \
    linux-firmware-ath9k \
    linux-firmware-ralink \
    linux-firmware-rtl8192cu \
"

CONNECTIVITY_FIRMWARES ?= ""

CONNECTIVITY_WIRELESS_PACKAGES = " \
    usb-modeswitch \
    wireless-tools \
    crda \
"

CONNECTIVITY_PACKAGES = " \
    ${NETWORK_MANAGER_PACKAGES} \
    dnsmasq \
    openvpn \
    openssh \
"

CONNECTIVITY_LORA_PACKAGES = " \
    udp-packet-forwarder \
    loriot-packet-forwarder \
    lora-basic-station \
	chirpstack-gateway-bridge \
    pmon-csgb-upf \
"

RDEPENDS_${PN} = " \
    ${CONNECTIVITY_MODULES} \
    ${CONNECTIVITY_FIRMWARES} \
    ${CONNECTIVITY_PACKAGES} \
    ${@bb.utils.contains('MACHINE_FEATURES','wireless',' \
        ${CONNECTIVITY_WIRELESS_FIRMWARES} \
        ${CONNECTIVITY_WIRELESS_PACKAGES} \
    ','',d)} \
    ${@bb.utils.contains('MACHINE_FEATURES','lora',' \
        ${CONNECTIVITY_LORA_PACKAGES} \
    ','',d)} \
"

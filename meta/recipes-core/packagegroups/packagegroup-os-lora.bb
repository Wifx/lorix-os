# Copyright (c) 2019, Wifx Sàrl <info@wifx.net>
# All rights reserved.

SUMMARY = "OS LoRa Package Group"
LICENSE = "Apache-2.0"

PR = "r0"

#
# packages which content depend on MACHINE_FEATURES need to be MACHINE_ARCH
#
PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS_${PN} = " \
    lora-basic-station \
    loriot-packet-forwarder \
"

# LORIX One
RDEPENDS_${PN}_append_lorix-one = " \
    udp-packet-forwarder \
    chirpstack-gateway-bridge \
    pmon-csgb-upf \
"
RRECOMMENDS_${PN}_append_lorix-one += " \
    pmon-csgb-concentratord \
    pmon-csub-concentratord \
    pmon-helium-upf \
" 

# Wifx L1
RDEPENDS_${PN}_append_l1 += " \
    pmon-csgb-concentratord \
    pmon-csub-concentratord \
"
RRECOMMENDS_${PN}_append_l1 += " \
    pmon-helium-csub-concentratord \
"

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

RDEPENDS_${PN}_lorix-one = " \
    udp-packet-forwarder \
    loriot-packet-forwarder \
    lora-basic-station \
    chirpstack-gateway-bridge \
    pmon-csgb-upf \
"

RRECOMMENDS_${PN}_lorix-one = " \
    chirpstack-concentratord \
    chirpstack-udp-bridge \
    helium-gateway \
    pmon-csgb-concentratord \
    pmon-csub-concentratord \
    pmon-helium-upf \
"

RDEPENDS_${PN}_l1 = " \
    lora-basic-station \
    pmon-csgb-concentratord \
    pmon-csub-concentratord \
    loriot-packet-forwarder \
"

RRECOMMENDS_${PN}_l1 = " \
    helium-gateway \
    pmon-helium-csub-concentratord \
"

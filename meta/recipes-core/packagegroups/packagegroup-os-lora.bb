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
"

RDEPENDS_${PN}_lorix-one = " \
    udp-packet-forwarder \
    loriot-packet-forwarder \
    lora-basic-station \
    chirpstack-gateway-bridge \
    pmon-csgb-upf \
"

RDEPENDS_${PN}_l1 = " \
    lora-basic-station \
    pmon-csgb-concentratord \
    pmon-csub-concentratord \
"

OPTIONAL_PACKAGES_${PN} = " \
    helium-gateway \
"

OPTIONAL_PACKAGES_${PN}_lorix-one = " \
    chirpstack-concentratord \
    chirpstack-udp-bridge \
    helium-gateway \
    pmon-csgb-concentratord \
    pmon-csub-concentratord \
    pmon-helium-upf \
" 

OPTIONAL_PACKAGES_${PN}_l1 = " \
    pmon-helium-csub-concentratord \
"

RRECOMMENDS_{PN} = "$OPTIONAL_PACKAGES_${PN}"
PACKAGE_EXCLUDE_{PN} = "$OPTIONAL_PACKAGES_${PN}"

RRECOMMENDS_{PN}_lorix-one = "$OPTIONAL_PACKAGES_${PN}_lorix-one"
PACKAGE_EXCLUDE_{PN}_lorix-one = "$OPTIONAL_PACKAGES_${PN}_lorix-one"

RRECOMMENDS_{PN}_l1 = "$OPTIONAL_PACKAGES_${PN}_l1"
PACKAGE_EXCLUDE_{PN}_l1 = "$OPTIONAL_PACKAGES_${PN}_l1"

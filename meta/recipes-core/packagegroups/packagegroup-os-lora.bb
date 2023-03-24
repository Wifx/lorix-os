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

RDEPENDS_${PN}_append_lorix-one = " \
    udp-packet-forwarder \
    chirpstack-gateway-bridge \
    pmon-csgb-upf \
"

RDEPENDS_${PN}_append_l1 = " \
    pmon-csgb-concentratord \
    pmon-csub-concentratord \
"

OPTIONAL_PACKAGES = " \
    helium-gateway \
"

OPTIONAL_PACKAGES_lorixone = " \
    chirpstack-concentratord \
    chirpstack-udp-bridge \
    helium-gateway \
    pmon-csgb-concentratord \
    pmon-csub-concentratord \
    pmon-helium-upf \
" 

OPTIONAL_PACKAGES_l1 = " \
    pmon-helium-csub-concentratord \
"

RRECOMMENDS_${PN} = "${OPTIONAL_PACKAGES}"
BAD_RECOMMENDATIONS_${PN} = "${OPTIONAL_PACKAGES}"

RRECOMMENDS_${PN}_lorix-one += "${OPTIONAL_PACKAGES_lorixone}"
BAD_RECOMMENDATIONS_${PN}_lorix-one += "${OPTIONAL_PACKAGES_lorixone}"

RRECOMMENDS_${PN}_l1 += "${OPTIONAL_PACKAGES_l1}"
BAD_RECOMMENDATIONS_${PN}_l1 += "${OPTIONAL_PACKAGES_l1}"

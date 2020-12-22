# Copyright (c) 2019-2020, Wifx Sàrl <info@wifx.net>
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
    loriot-packet-forwarder \
    lora-basic-station \
    pmon-csgb-upf \
    pmon-csgb-concentratord \
    pmon-udp-concentratord \
"

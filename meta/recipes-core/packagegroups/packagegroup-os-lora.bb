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

RDEPENDS:${PN} = " \
    lora-basic-station \
    loriot-packet-forwarder \
    pmon-csmf-concentratord \
"
RRECOMMENDS:${PN}:append = " \
" 

# LORIX One
RDEPENDS:${PN}:append:lorix-one = " \
    pmon-csgb-upf \
"
RRECOMMENDS:${PN}:append:lorix-one = " \
    pmon-csgb-concentratord \
    pmon-csuf-concentratord \
    pmon-helium-upf \
" 

# Wifx L1
RDEPENDS:${PN}:append:l1 = " \
    pmon-csgb-concentratord \
    pmon-csuf-concentratord \
"
RRECOMMENDS:${PN}:append:l1 = " \
    pmon-helium-csuf-concentratord \
"

# Copyright (c) 2019, Wifx Sàrl <info@wifx.net>
# All rights reserved.

SUMMARY = "OS Machine related package group"
LICENSE = "Apache-2.0"

PR = "r0"

#
# packages which content depend on MACHINE_FEATURES need to be MACHINE_ARCH
#
PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

MACHINE_EXTRA_RDEPENDS ?= ""
MACHINE_EXTRA_RRECOMMENDS ?= ""

RDEPENDS:${PN} = " \
    ${MACHINE_EXTRA_RDEPENDS} \
    libgpiod \
"

RRECOMMENDS:${PN} = " \
    ${MACHINE_EXTRA_RRECOMMENDS} \
"

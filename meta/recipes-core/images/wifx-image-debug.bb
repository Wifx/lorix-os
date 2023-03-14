# Copyright (c) 2019-2020, Wifx Sàrl <info@wifx.net>
# All rights reserved.

DESCRIPTION = "A debug image with debugging utils and without password (root user)"
LICENSE = "MIT"
PR = "r0"

inherit wifx-image-core wifx-image-base-users

IMAGE_INSTALL += " \
    packagegroup-os-dev-utils \
    gdb \
    chirpstack-concentratord \
    pmon-csgb-concentratord \
    binutils \
"

IMAGE_INSTALL_append_lorix-one = " \
    libloragw-sx1301-utils \
    libloragw-sx1301-tests \
"

IMAGE_INSTALL_append_l1 = " \
    libloragw-sx1302-utils \
    libloragw-sx1302-tests \
"

EXTRA_IMAGE_FEATURES ?= " tools-debug debug-tweaks"

# Copyright (c) 2026, Wifx SA <info@wifx.net>
# All rights reserved.

SUMMARY = "OS optional package group"
DESCRIPTION = "Packages published in the OPKG feed but not installed in the images. \
They are meant to be installed on demand by the user with 'opkg install'. \
This packagegroup must never be added to an IMAGE_INSTALL."
LICENSE = "Apache-2.0"

PR = "r0"

inherit packagegroup

# package_ipk only requests the ipk of the direct RDEPENDS, which would publish an
# unresolvable feed. Request the whole recursive runtime dependency chain instead.
do_build[recrdeptask] += "do_package_write_ipk"

# recrdeptask does not follow RRECOMMENDS, only use RDEPENDS here.
RDEPENDS:${PN} = " \
    arptables \
    curl \
    ebtables \
    iftop \
    iperf3 \
    netcat \
    nethogs \
    tcpdump \
    traceroute \
    tunctl \
    \
    memtester \
    net-tools \
    i2c-tools \
"

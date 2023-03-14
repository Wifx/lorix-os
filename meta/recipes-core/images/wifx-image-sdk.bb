# Copyright (c) 2019-2020, Wifx Sàrl <info@wifx.net>
# All rights reserved.

DESCRIPTION = "An image containing all the possible packages to be installed through OPKG and needed to have a complete toolchain."
LICENSE = "MIT"
PR = "r0"

inherit wifx-image-core wifx-image-base-users

# Additionnal packages
IMAGE_INSTALL += " \
    packagegroup-os-dev-utils \
    \
    python \
    python-psutil \
    python-ujson \
    python-cryptography \
    python-pyserial \
    python-setuptools \
    \
    python3 \
    python3-pip \
    python3-setuptools \
    \
    mtd-utils-tests \
    \
    curl \
    \
    arptables \
    ebtables \
    dnsmasq \
    iftop \
    net-snmp \
    netcat \
    openvpn \
    traceroute \
    tunctl \
    tcpdump \
    lighttpd \
    \
    networkmanager-nmtui \
"

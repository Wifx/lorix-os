# Copyright (c) 2019, Wifx Sàrl <info@wifx.net>
# All rights reserved.

SUMMARY = "OS extended package group"
LICENSE = "Apache-2.0"

PR = "r0"

inherit packagegroup

RDEPENDS_${PN} = " \
    iproute2 \
    iptables \
    bridge-utils \
    bind-utils \
    \
    openssl \
    openssl-misc \
    ca-certificates \
"

OPTIONAL_PACKAGES_${PN} = " \
    net-snmp-server \
    zabbix \
"

RRECOMMENDS_{PN} = "$OPTIONAL_PACKAGES_${PN}"
PACKAGE_EXCLUDE_{PN} = "$OPTIONAL_PACKAGES_${PN}"

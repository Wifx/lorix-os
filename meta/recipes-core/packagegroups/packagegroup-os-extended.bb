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
RRECOMMENDS_${PN} += " \
    net-snmp-server \
    zabbix \
"

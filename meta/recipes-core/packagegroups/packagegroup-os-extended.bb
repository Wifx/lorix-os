# Copyright (c) 2019, Wifx Sàrl <info@wifx.net>
# All rights reserved.

SUMMARY = "OS extended package group"
LICENSE = "Apache-2.0"

PR = "r0"

inherit packagegroup

# Configure firewall backend: nftables (default) or iptables
FIREWALL_BACKEND ??= "nftables"

RDEPENDS:${PN} = " \
    iproute2 \
    ${@bb.utils.contains('FIREWALL_BACKEND', 'nftables', 'nftables', 'iptables', d)} \
    openssl \
    ca-certificates \
"
RRECOMMENDS:${PN} += " \
    bind-utils \
    bridge-utils \
    net-snmp-server \
    nethogs \
    iperf3 \
    zabbix \
"

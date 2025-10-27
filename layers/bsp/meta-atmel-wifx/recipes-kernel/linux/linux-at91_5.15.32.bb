require linux-at91-common.inc
LIC_FILES_CHKSUM = "file://COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"

LINUX_VERSION_SHORT = "5.15"
LINUX_VERSION ?= "5.15.32"
LINUX_VERSION_EXTENSION = "-wifx"

FILESEXTRAPATHS:prepend = "${THISDIR}/${PN}-${LINUX_VERSION_SHORT}:${THISDIR}/${PN}-${LINUX_VERSION_SHORT}/kernel-features:"

SRCREV_machine = "7d6b6eb000ec3866db59efd992683f3f9353cdd2"
SRCREV_meta = "578937826ffad97749eba3a5d1b21b37b5cd7bdc"

PR ?= "r0"
S ?= "${WORKDIR}/git"

SRC_URI += " \
    file://defconfig \
    ${@bb.utils.contains('MACHINE_FEATURES', 'wwan', 'file://cdc-ether.cfg', '', d)} \
"

SRC_URI:append:l1 = " \
    file://l1.cfg \
"

SRC_URI:append:lorix-one = " \
    file://lorix.cfg \
"

KERNEL_EXTRA_FEATURES ?= " \
    ${@bb.utils.contains('IMAGE_FEATURES', 'debug-tweaks', 'features/debug/debug-kernel.scc', '', d)} \
    features/netfilter/netfilter.scc \
    features/nf_tables/nf_tables.scc \
    ${@bb.utils.contains('DISTRO_FEATURES', 'ipv6', ' \
        cfg/net/ipv6.scc \
        cfg/net/ip6_nf.scc \
    ', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wireguard', 'kernel-meta-extra/wireguard/wireguard.scc', '', d)} \
"

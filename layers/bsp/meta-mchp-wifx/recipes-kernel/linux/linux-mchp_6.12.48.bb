require linux-mchp.inc
LIC_FILES_CHKSUM = "file://COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"

LINUX_VERSION_SHORT = "6.12"
LINUX_VERSION ?= "6.12.48"
LINUX_VERSION_EXTENSION = "-wifx"
KERNEL_VERSION_SANITY_SKIP = "1"
KBRANCH = "linux-${LINUX_VERSION_SHORT}-mchp-wifx"
KBUILD_DEFCONFIG = ""

FILESEXTRAPATHS:prepend = "${THISDIR}/${PN}-${LINUX_VERSION}:"

SRCREV_machine = "09c915bc2d12b2bb180762160854ac0ea929aa70"
SRCREV_meta = "7a8d96185b9be165feb974fe6297b518f83b3b9c"

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
    features/netfilter/netfilter.scc \
    features/nf_tables/nf_tables.scc \
    features/cgroups/cgroups.scc \
    ${@bb.utils.contains('DISTRO_FEATURES', 'ipv6', ' \
        cfg/net/ipv6.scc \
        cfg/net/ip6_nf.scc \
    ', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wireguard', ' \
        kernel-meta-extra/wireguard/wireguard.scc \
    ', '', d)} \
    ${@bb.utils.contains('IMAGE_FEATURES', 'debug-tweaks', ' \
        features/debug/debug-dyndbg.scc \
        features/debug/debug-kernel.scc \
        features/debug/debug-runtime.scc \
        features/debug/printk.scc \
    ', '', d)} \
"

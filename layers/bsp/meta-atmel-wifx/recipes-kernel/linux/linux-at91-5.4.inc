FILESEXTRAPATHS_prepend = "${THISDIR}/${PN}-5.4:"

require linux-at91-common.inc
LIC_FILES_CHKSUM = "file://COPYING;md5=bbea815ee2795b2f4230826c0c6b8814"

LINUX_VERSION_EXTENSION = "-wifx"

PR ?= "r0"
S ?= "${WORKDIR}/git"

SRC_URI += " \
    file://defconfig \
    file://kernel-features/debug/debug.scc;type=kmeta;destsuffix=kernel-meta \
    file://kernel-features/debug/debug.cfg \
    file://kernel-features/netfilter/netfilter.scc;type=kmeta;destsuffix=kernel-meta \
    file://kernel-features/netfilter/netfilter.cfg \
    file://kernel-features/netfilter/netfilter6.scc;type=kmeta;destsuffix=kernel-meta \
    file://kernel-features/netfilter/netfilter6.cfg \
    file://kernel-features/nf_tables/nf_tables.scc;type=kmeta;destsuffix=kernel-meta \
    file://kernel-features/nf_tables/nf_tables.cfg \
    file://kernel-features/nf_tables/nf_tables6.scc;type=kmeta;destsuffix=kernel-meta \
    file://kernel-features/nf_tables/nf_tables6.cfg \
    file://kernel-features/wireguard/wireguard.scc;type=kmeta;destsuffix=kernel-meta \
    file://kernel-features/wireguard/wireguard.cfg \
    file://0001-l1-add-support-for-the-Wifx-L1-board.patch \
"

SRC_URI_append_l1 = " \
    file://l1.cfg \
"

SRC_URI_append_lorix-one = " \
    file://lorix.cfg \
"

KERNEL_EXTRA_FEATURES ?= " \
    ${@bb.utils.contains('IMAGE_FEATURES', 'debug-tweaks', 'kernel-features/debug/debug.scc', '', d)} \
    kernel-features/netfilter/netfilter.scc \
    ${@bb.utils.contains('DISTRO_FEATURES', 'ipv6', 'kernel-features/netfilter/netfilter6.scc', '', d)} \
    kernel-features/nf_tables/nf_tables.scc \
    ${@bb.utils.contains('DISTRO_FEATURES', 'ipv6', 'kernel-features/nf_tables/nf_tables6.scc', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wireguard', 'kernel-features/wireguard/wireguard.scc', '', d)} \
"

FILESEXTRAPATHS_prepend := "${THISDIR}/${P}:"

include linux-at91-common.inc
LIC_FILES_CHKSUM = "file://COPYING;md5=bbea815ee2795b2f4230826c0c6b8814"

#LINUX_VERSION ?= "5.4.41"
LINUX_VERSION ?= "5.4.104"
LINUX_VERSION_EXTENSION = "-wifx"

PR = "r0"

S = "${WORKDIR}/git"

#SRCREV = "4eedead4a4e1bb708d5b1629a9749d46a878406e"
#KBRANCH = "linux-5.4-at91"
SRCREV = "ddc86f7db87cc248e6126c6aeb085382c8770964"
KBRANCH = "linux-5.4.104-at91"

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
    file://0001-Add-original-support-for-the-Wifx-L1-gateway.patch \
"

SRC_URI_append_lorix = " \
    file://lorix.cfg \
"

SRC_URI_append_l1 = " \
    file://l1.cfg \
"

KERNEL_EXTRA_FEATURES ?= " \
    ${@bb.utils.contains('EXTRA_IMAGE_FEATURES', 'debug-tweaks', 'kernel-features/debug/debug.scc', '', d)} \
    kernel-features/netfilter/netfilter.scc \
    ${@bb.utils.contains('DISTRO_FEATURES', 'ipv6', 'kernel-features/netfilter/netfilter6.scc', '', d)} \
    kernel-features/nf_tables/nf_tables.scc \
    ${@bb.utils.contains('DISTRO_FEATURES', 'ipv6', 'kernel-features/nf_tables/nf_tables6.scc', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wireguard', 'kernel-features/wireguard/wireguard.scc', '', d)} \
"

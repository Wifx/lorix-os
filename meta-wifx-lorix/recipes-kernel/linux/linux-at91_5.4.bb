FILESEXTRAPATHS_prepend := "${THISDIR}/${P}:"

include linux-at91-common.inc
LIC_FILES_CHKSUM = "file://COPYING;md5=bbea815ee2795b2f4230826c0c6b8814"

LINUX_VERSION ?= "5.4.41"
LINUX_VERSION_EXTENSION = "-wifx"

PR = "r0"

S = "${WORKDIR}/git"

SRCREV = "4598c555c6afda4a9df920413667ba508368356b"
KBRANCH = "linux-5.4-at91"

SRC_URI += " \
    file://kernel-features/netfilter/netfilter.scc;type=kmeta;destsuffix=kernel-meta \
    file://kernel-features/netfilter/netfilter6.scc;type=kmeta;destsuffix=kernel-meta \
    file://kernel-features/nf_tables/nf_tables.scc;type=kmeta;destsuffix=kernel-meta \
    file://kernel-features/nf_tables/nf_tables6.scc;type=kmeta;destsuffix=kernel-meta \
"

KERNEL_EXTRA_FEATURES ?= " \
    kernel-features/netfilter/netfilter.scc \
    ${@bb.utils.contains('DISTRO_FEATURES', 'ipv6', 'kernel-features/netfilter/netfilter6.scc', '', d)} \
    kernel-features/nf_tables/nf_tables.scc \
    ${@bb.utils.contains('DISTRO_FEATURES', 'ipv6', 'kernel-features/nf_tables/nf_tables6.scc', '', d)} \
    "

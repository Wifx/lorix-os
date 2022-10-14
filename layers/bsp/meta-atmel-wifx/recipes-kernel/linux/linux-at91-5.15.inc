FILESEXTRAPATHS_prepend = "${THISDIR}/${PN}-5.15:"

require linux-at91-common.inc
LIC_FILES_CHKSUM = "file://COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"

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
    file://0001-Add-optionnal-customization-of-Atmel-NAND-PMECC-para.patch \
    file://0002-Add-i2c3-bus-support-for-SAMA5D4x-family-processor-i.patch \
    file://0003-wifx-Add-base-support-for-Wifx-LORIX-One-machine.patch \
    file://0004-wifx-Add-base-support-for-Wifx-L1-machine.patch \
    file://0005-mtdblock-warning-using-mtd-device-instead-of-UBI-is-.patch \
    file://0006-wifx-l1-lorix-remove-warning-about-dummy-vcc-regulat.patch \
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

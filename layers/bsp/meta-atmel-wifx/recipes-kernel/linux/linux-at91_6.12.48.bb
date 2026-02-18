require linux-at91-6.12.inc
LIC_FILES_CHKSUM = "file://COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"

LINUX_VERSION_SHORT = "6.12"
LINUX_VERSION ?= "6.12.48"
LINUX_VERSION_EXTENSION = "-wifx"
KERNEL_VERSION_SANITY_SKIP = "1"
KBRANCH = "linux-${LINUX_VERSION_SHORT}-mchp"

FILESEXTRAPATHS:prepend = "${THISDIR}/${PN}-${LINUX_VERSION_SHORT}:${THISDIR}/${PN}-${LINUX_VERSION_SHORT}/kernel-features:"

SRCREV_machine = "697adef71105d3d23d0e1da18ed3c2fd483cf0c8"
SRCREV_meta = "7a8d96185b9be165feb974fe6297b518f83b3b9c"

PR ?= "r0"
S ?= "${WORKDIR}/git"

SRC_URI += " \
    file://defconfig \
    ${@bb.utils.contains('MACHINE_FEATURES', 'wwan', 'file://cdc-ether.cfg', '', d)} \
    file://0001-Add-optionnal-customization-of-Atmel-NAND-PMECC-para.patch \
    file://0002-Add-i2c3-bus-support-for-SAMA5D4x-family-processor-i.patch \
    file://0003-lte-add-Fibocom-L610-MC610-support-in-option-driver.patch \
    file://0004-net-macb-manage-BNA-error-and-prevent-RX-lockup-on-G.patch \
    file://0005-wifx-Add-base-support-for-Wifx-LORIX-One-machine.patch \
    file://0006-wifx-Add-base-support-for-Wifx-L1-machine.patch \
    file://0007-wifx-Migrate-support-for-Wifx-machine-to-kernel-6.12.patch \
"

SRC_URI:append:l1 = " \
    file://l1.cfg \
    file://l1-wgw.cfg \
"

SRC_URI:append:lorix-one = " \
    file://lorix.cfg \
"

#SRC_URI:append:l1 = " \
#    file://l1-wgw-devel.cfg \
#"

KERNEL_EXTRA_FEATURES ?= " \
    ${@bb.utils.contains('IMAGE_FEATURES', 'debug-tweaks', 'features/debug/debug-kernel.scc', '', d)} \
    features/netfilter/netfilter.scc \
    features/nf_tables/nf_tables.scc \
    features/cgroups/cgroups.scc \
    ${@bb.utils.contains('DISTRO_FEATURES', 'ipv6', ' \
        cfg/net/ipv6.scc \
        cfg/net/ip6_nf.scc \
    ', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wireguard', 'kernel-meta-extra/wireguard/wireguard.scc', '', d)} \
"
KERNEL_EXTRA_FEATURES ?= ""
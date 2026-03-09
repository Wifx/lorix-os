DESCRIPTION = "Linux kernel for Microchip SoCs"
SECTION = "kernel"
SUMMARY = "kernel"
LICENSE = "GPL-2.0-only"

inherit kernel-yocto kernel

# Do not include by default the kernel-image
RDEPENDS:${KERNEL_PACKAGE_NAME}-base = ""

PV = "${LINUX_VERSION}${LINUX_VERSION_EXTENSION}"

KMACHINE ?= "${MACHINE}"
KCONFIG_MODE="--alldefconfig"
KMETA = "kernel-meta"
KBRANCH = "linux-${LINUX_VERSION_SHORT}-mchp-wifx"
KERNEL_VERSION_SANITY_SKIP = "1"

S ?= "${WORKDIR}/git"

SRC_URI = " \
    git://github.com/Wifx/linux4mchp.git;name=machine;branch=${KBRANCH};protocol=https \
    git://git.yoctoproject.org/yocto-kernel-cache;type=kmeta;name=meta;branch=yocto-${LINUX_VERSION_SHORT};destsuffix=${KMETA};protocol=https; \
    file://defconfig \
    ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'file://systemd.cfg', '', d)} \
    ${@bb.utils.contains('MACHINE_FEATURES', 'wwan', 'file://cdc-ether.cfg', '', d)} \
"

SRC_URI:append:l1 = " \
    file://l1.cfg \
"

SRC_URI:append:lorix-one = " \
    file://lorix.cfg \
"

# we use defconfig through SRC_URI so we don't want to use the kernel source'
KBUILD_DEFCONFIG = ""

FILESEXTRAPATHS:prepend = "${THISDIR}/${PN}-${LINUX_VERSION_SHORT}:"

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
KERNEL_FEATURES:append = " ${KERNEL_EXTRA_FEATURES}"

KERNEL_MODULE_AUTOLOAD += ""
KERNEL_MODULE_PACKAGE_SUFFIX=""

COMPATIBLE_MACHINE = "sama5d4-wifx"

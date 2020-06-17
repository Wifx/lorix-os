FILESEXTRAPATHS_prepend := "${THISDIR}/${P}:"

include linux-at91-common.inc

LINUX_VERSION ?= "4.14.88"
LINUX_VERSION_EXTENSION = "-wifx"

PR = "r0"

S = "${WORKDIR}/git"

SRCREV = "7a97d92d6aca292393ca610949eabf3006e3b188"
KBRANCH = "linux-4.14-at91"

SRC_URI += " \
    file://0001-Mofified-main-LED-name-simplified-to-status.patch \
    file://0002-Replaced-tabs-by-spaces-in-pmic-lorix-driver.patch \
    file://0003-Added-sysfs-product-class-support-and-cache-for-mach.patch \
    file://0004-Add-device-version-for-machine-product-sysfs-entry.patch \
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

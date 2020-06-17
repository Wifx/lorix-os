FILESEXTRAPATHS_prepend := "${THISDIR}/${P}:"

include linux-at91-common.inc

LINUX_VERSION ?= "4.9.127"
LINUX_VERSION_EXTENSION = "-wifx"

PR = "r0"

S = "${WORKDIR}/git"

SRCREV = "ee2f16141362e7c0d249b7f2dba7f5a9721b8346"
KBRANCH = "linux-4.9-at91"

# Kernel meta have been including since Kernel 4.14
KERNEL_EXTRA_FEATURES = ""

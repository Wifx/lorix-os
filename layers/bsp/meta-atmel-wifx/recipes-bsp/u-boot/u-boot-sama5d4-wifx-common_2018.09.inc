HOMEPAGE = "http://www.denx.de/wiki/U-Boot/WebHome"
SECTION = "bootloaders"
DEPENDS += "flex-native bison-native"

LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://Licenses/README;md5=30503fd321432fc713238f582193b78e"

# We use the revision in order to avoid having to fetch it from the
# repo during parse
SRCREV = "f88b6facb87dc4a52f1630eb9d858c0f54c6628e"
PV = "v2018.09-wifx"

UBOOT_FW_ENV_FILE ?= "fw_env_${MACHINE}.config"

FILESEXTRAPATHS_prepend := "${THISDIR}/files/v2018.09-wifx:"
SRC_URI += " \
    git://github.com/u-boot/u-boot.git;protocol=https \
    file://0001-Change-extraversion-to-wifx.patch \
    file://0002-Add-LORIX-One-support.patch \
    file://0003-Overwrite-existing-MMC-env-MAC-address-if-differ-fro.patch \
    file://0001-Add-Wifx-L1-machine-support.patch \
"

S = "${WORKDIR}/git"

COMPATIBLE_MACHINE = "sama5d4-wifx"
PACKAGE_ARCH = "${MACHINE_ARCH}"

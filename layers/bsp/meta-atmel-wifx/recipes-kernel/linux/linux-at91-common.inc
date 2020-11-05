SECTION = "kernel"
DESCRIPTION = "Linux kernel for Atmel ARM SoCs (aka AT91)"
SUMMARY = "Linux kernel for Atmel ARM SoCs (aka AT91)"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=d7810fab7487fb0aad327b76f1be7cd7"

inherit kernel
require recipes-kernel/linux/linux-yocto.inc

# Do not include by default the kernel-image
RDEPENDS_${KERNEL_PACKAGE_NAME}-base = ""

PV = "${LINUX_VERSION}${LINUX_VERSION_EXTENSION}"

SRC_URI = " \
    git://github.com/Wifx/linux-at91.git;protocol=git;branch=${KBRANCH} \
    file://defconfig \
    ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'file://systemd.cfg', '', d)} \
"

KMACHINE ?= "${MACHINE}"
KCONFIG_MODE="--alldefconfig"

python __anonymous () {
    if d.getVar('UBOOT_FIT_IMAGE', True) == 'xyes':
        d.appendVar('DEPENDS', ' u-boot-mkimage-native dtc-native')
}

do_deploy_append() {
    if [ "${UBOOT_FIT_IMAGE}" = "xyes" ]; then
        DTB_PATH="${B}/arch/${ARCH}/boot/dts/"
        if [ ! -e "${DTB_PATH}" ]; then
            DTB_PATH="${B}/arch/${ARCH}/boot/"
        fi

        if [ -e ${S}/arch/${ARCH}/boot/dts/${MACHINE}.its ]; then
            cp ${S}/arch/${ARCH}/boot/dts/${MACHINE}*.its ${DTB_PATH}
            cd ${DTB_PATH}
            mkimage -f ${MACHINE}.its ${MACHINE}.itb
            install -m 0644 ${MACHINE}.itb ${DEPLOYDIR}/${MACHINE}.itb
            cd -
        fi
    fi
}

kernel_do_configure_prepend() {
    # Create empty scmversion to remove the "+" at end of the kernel version
    echo "" > "${B}/.scmversion"
}

kernel_do_configure_append() {
    cd ${S}; git status; cd -
}

KERNEL_FEATURES_append = " ${KERNEL_EXTRA_FEATURES}"

KERNEL_MODULE_AUTOLOAD += "atmel_usba_udc g_serial"
KERNEL_MODULE_PACKAGE_SUFFIX=""

COMPATIBLE_MACHINE = "sama5d4-wifx"

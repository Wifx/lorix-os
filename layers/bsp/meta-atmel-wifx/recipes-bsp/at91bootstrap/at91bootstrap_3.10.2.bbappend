# Copyright (c) 2022, Wifx SA <info@iot.wifx.net>
# All rights reserved.

# Don't use git commit in package version
PV = "3.10.2"

FILESEXTRAPATHS:prepend := "${THISDIR}/at91bootstrap-${PV}:"

SRC_URI += " \
    file://0001-Change-revision-to-wifx.patch \
    file://0002-Add-base-support-for-Wifx-LORIX-One-machine.patch \
    file://0003-Add-base-support-for-Wifx-L1-machine.patch \
    file://0004-Fix-nostartfiles-flag-passed-to-ld-instead-of-gcc.patch \
"

COMPATIBLE_MACHINE = "sama5d4-wifx"

AT91BOOTSTRAP_MACHINE:sama5d4-wifx ??= "${@'${MACHINE}'.replace('-', '_')}"
AT91BOOTSTRAP_CONFIG:sama5d4-wifx ??= "${AT91BOOTSTRAP_MACHINE}_${@bb.utils.contains("IMAGE_FEATURES", "sdcard_variant", "sd", "nf", d)}_uboot"
AT91BOOTSTRAP_TARGET:sama5d4-wifx ??= "${AT91BOOTSTRAP_CONFIG}_defconfig"
AT91BOOTSTRAP_LOAD:sama5d4-wifx ??= "${@bb.utils.contains("IMAGE_FEATURES", "sdcard_variant", "sdboot", "nandflashboot", d)}-uboot"

do_configure:prepend:sama5d4-wifx() {
	if [ -f "${S}/contrib/board/wifx/${AT91BOOTSTRAP_MACHINE}/${AT91BOOTSTRAP_TARGET}" ] && [ ! -f "${B}/.config" ]; then
		cp "${S}/contrib/board/wifx/${AT91BOOTSTRAP_MACHINE}/${AT91BOOTSTRAP_TARGET}" "${B}/.config"
	fi
}

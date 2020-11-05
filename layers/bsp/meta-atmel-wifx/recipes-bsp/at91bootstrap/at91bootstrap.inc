# Copyright (c) 2019-2020, Wifx Sàrl <info@wifx.net>
# All rights reserved.

COMPATIBLE_MACHINE = "sama5d4-wifx"

AT91BOOTSTRAP_MACHINE ??= "${@'${MACHINE}'.replace('-', '_')}"

AT91BOOTSTRAP_CONFIG_sama5d4-wifx ??= "${AT91BOOTSTRAP_MACHINE}_${@bb.utils.contains("IMAGE_FEATURES", "sdcard_variant", "sd", "nf", d)}_uboot"
AT91BOOTSTRAP_TARGET_sama5d4-wifx ??= "${AT91BOOTSTRAP_CONFIG}_defconfig"
AT91BOOTSTRAP_LOAD_sama5d4-wifx ??= "${@bb.utils.contains("IMAGE_FEATURES", "sdcard_variant", "sdboot", "nandflashboot", d)}-uboot"

do_configure_prepend_sama5d4-wifx() {
	if [ -f "${S}/contrib/board/wifx/${AT91BOOTSTRAP_MACHINE}/${AT91BOOTSTRAP_TARGET}" ] && [ ! -f "${B}/.config" ]; then
		cp "${S}/contrib/board/wifx/${AT91BOOTSTRAP_MACHINE}/${AT91BOOTSTRAP_TARGET}" "${B}/.config"
	fi
}

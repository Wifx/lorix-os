require u-boot-wifx-common_${PV}.inc
require u-boot-wifx.inc

DEPENDS += "bc-native dtc-native"

UBOOT_ENV_SOURCE_SUFFIX = "env"
UBOOT_ENV_lorix-one-256 = "${@bb.utils.contains('DISTRO_FEATURES', 'mender', 'mender-256', 'default-256', d)}"
UBOOT_ENV_lorix-one-512 = "${@bb.utils.contains('DISTRO_FEATURES', 'mender', 'mender-512', 'default-512', d)}"

SRC_URI += " file://${UBOOT_ENV_SOURCE}"

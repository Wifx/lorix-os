require u-boot-sama5d4-wifx-common_${PV}.inc
require u-boot-sama5d4-wifx.inc

DEPENDS += "bison-native flex-native"

UBOOT_ENV_SOURCE_SUFFIX = "env"
UBOOT_ENV_lorix-one-256 = "${@bb.utils.contains('DISTRO_FEATURES', 'mender', 'mender-256', 'default-256', d)}"
UBOOT_ENV_lorix-one-512 = "${@bb.utils.contains('DISTRO_FEATURES', 'mender', 'mender-512', 'default-512', d)}"
UBOOT_ENV_l1 = "${@bb.utils.contains('DISTRO_FEATURES', 'mender', 'mender-l1', 'default-l1', d)}"

SRC_URI += " file://${UBOOT_ENV_SOURCE}"

PROVIDES += "u-boot"
RPROVIDES_${PN} += "u-boot"

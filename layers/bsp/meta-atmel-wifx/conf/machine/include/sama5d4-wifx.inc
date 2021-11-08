# Copyright (c) 2019-2020, Wifx Sàrl <info@wifx.net>
# All rights reserved.

require conf/machine/include/sama5d4.inc

# the machine is more generally a Wifx product based on SAMA5D4 CPU
MACHINEOVERRIDES =. "sama5d4-wifx:"

# Perhaps wimg and tar.bz2 could be moved in distro or image recipe
IMAGE_FSTYPES += "ubimg wimg tar.bz2"

# Preferred providers
PREFERRED_PROVIDER_virtual/firststage_sama5d4-wifx = "at91bootstrap"
PREFERRED_PROVIDER_virtual/bootloader_sama5 = "u-boot-sama5d4-wifx"
PREFERRED_PROVIDER_u-boot_sama5 = "u-boot-sama5d4-wifx"
PREFERRED_PROVIDER_virtual/kernel_sama5d4-wifx = "linux-at91"
PREFERRED_PROVIDER_u-boot-fw-utils_sama5d4-wifx = "u-boot-sama5d4-wifx-fw-utils"
PREFERRED_PROVIDER_u-boot-mkenvimage-native = "u-boot-mkenvimage-native"
PREFERRED_VERSION_linux-at91_sama5d4-wifx ?= "5.4%"

# Linux kernel specific variables
KERNEL_DEVICETREE = "${MACHINE}.dtb"
KERNEL_IMAGETYPE = "zImage"

# U-Boot bootloader specific variables
UBOOT_MACHINE ?= "${@'${MACHINE}'.replace('-', '_')}_nandflash_config"
UBOOT_ENTRYPOINT = "0x20008000"
UBOOT_LOADADDRESS = "0x20008000"
UBOOT_ENV_SIZE = "0x20000"

# Mender update system specific variables
MENDER_MTDIDS = "nand0=atmel_nand"
MENDER_MTDPARTS = "atmel_nand:256k(bootstrap)ro,768k(uboot)ro,512k(uboot-env),-(ubi)"
MENDER_BOOT_PART_SIZE_MB = "0"
MENDER_RESERVED_SPACE_BOOTLOADER_DATA = "0x180000"
MENDER_UBOOT_ENV_STORAGE_DEVICE_OFFSET_1 = "0x140000"
MENDER_UBOOT_ENV_STORAGE_DEVICE_OFFSET_2 = "0x100000"

# used by sysvinit_2
SERIAL_CONSOLES = "115200;ttyS0 115200;ttyGS0"
SYSVINIT_ENABLED_GETTYS = ""
USE_VT = "0"

MACHINE_FEATURES += "rtc usbgadget usbhost"
MACHINE_EXTRA_RRECOMMENDS += "mtd-utils mtd-utils-ubifs"

# Packages required ideally at boot (as rrecommend and not rdepends to avoid build error on kernel version change)
MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS += "kernel-devicetree kernel-image"
MACHINE_ESSENTIAL_EXTRA_RDEPENDS += "kernel-modules"

# make sure that kernel and devicetree are installed
IMAGE_INSTALL_append = " kernel-devicetree kernel-image-zimage"

# Remove unused dependency which makes the build fail during the do_fetch
EXTRA_IMAGEDEPENDS_remove = "sam-ba-native"

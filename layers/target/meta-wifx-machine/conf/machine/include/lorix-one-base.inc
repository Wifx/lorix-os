# The CPU of the LORIX One is an SAMA5D41 from Microchip (Atmel)
require sama5d4.inc

# Preferred providers
PREFERRED_PROVIDER_virtual/bootloader_sama5 = "u-boot-wifx"
PREFERRED_PROVIDER_u-boot_sama5 = "u-boot-wifx"
PREFERRED_PROVIDER_virtual/kernel_sama5 = "linux-at91"
PREFERRED_PROVIDER_u-boot-fw-utils = "u-boot-wifx-fw-utils"
PREFERRED_PROVIDER_u-boot-mkenvimage-native = "u-boot-mkenvimage-native"
PREFERRED_VERSION_linux-at91_sama5 = "5.4%"

# used by sysvinit_2
SERIAL_CONSOLES = "115200;ttyS0 115200;ttyGS0"
SYSVINIT_ENABLED_GETTYS = ""
USE_VT = "0"

MACHINE_FEATURES = "rtc usbgadget usbhost lora"
MACHINE_EXTRA_RRECOMMENDS += "mtd-utils mtd-utils-ubifs"

# Packages required ideally at boot (as rrecommend and not rdepends to avoid build error on kernel version change)
MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS += "kernel-devicetree kernel-image"
MACHINE_ESSENTIAL_EXTRA_RDEPENDS += "kernel-modules"

# make sure that kernel and devicetree are installed
IMAGE_INSTALL_append = " kernel-devicetree kernel-image-zimage"

MACHINE_FEATURES += "sx1301"
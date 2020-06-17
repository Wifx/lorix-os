# The machine needs reset-lgw to manage the SX1301 reset line
MACHINE_EXTRA_RDEPENDS += " \
    u-boot-fw-utils \
    reset-lgw \
    mtd-utils \
    mtd-utils-ubifs \
"

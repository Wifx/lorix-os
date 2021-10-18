# The machine needs lora-concentrator to manage the LoRa concentrator reset line
MACHINE_EXTRA_RDEPENDS += " \
    u-boot-fw-utils \
    lora-concentrator \
    mtd-utils \
    mtd-utils-ubifs \
"

MACHINE_EXTRA_RDEPENDS_l1 += " \
    led-service \
"

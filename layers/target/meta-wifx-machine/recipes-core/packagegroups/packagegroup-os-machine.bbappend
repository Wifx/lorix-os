# The machine needs lora-concentrator to manage the LoRa concentrator reset line
MACHINE_EXTRA_RDEPENDS:append = " \
    u-boot-fw-utils \
    lora-concentrator \
    mtd-utils \
    mtd-utils-ubifs \
    machine-nm-config \
"

MACHINE_EXTRA_RDEPENDS:append:l1 = " \
    led-service \
    wgw-ec-util \
"

# Copyright (c) 2019, Wifx Sàrl <info@wifx.net>
# All rights reserved.

# The CPU of the LORIX One is a SAMA5D41 from Microchip (Atmel)
require conf/machine/include/sama5d4-wifx.inc

# the machine is more generally a Wifx LORIX One (mem size apart)
MACHINEOVERRIDES =. "lorix-one:"

MACHINE_FEATURES_OVERRIDES += "sx1301"

MACHINE_PRETTY_NAME = "LORIX One"

# Copyright (c) 2025, Wifx SA <info@iot.wifx.net>
# All rights reserved.

SRCREV = "ff1689b835630e888a659c01eca8ec4f2c1bdfa5"
SRC_URI += " \
    git://github.com/Wifx/chirpstack-gateway-mesh.git;protocol=https;branch=master \
"
PR = "r0"

require chirpstack-gateway-mesh.inc
require chirpstack-gateway-mesh-crates_${PV}.inc


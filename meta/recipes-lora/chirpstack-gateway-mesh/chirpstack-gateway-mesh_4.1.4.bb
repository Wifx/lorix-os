# Copyright (c) 2025, Wifx SA <info@iot.wifx.net>
# All rights reserved.

SRCREV = "d9a14b32e6413139538cef1121b3c586a8099ea9"
SRC_URI += " \
    git://github.com/chirpstack/chirpstack-gateway-mesh.git;protocol=https;branch=master \
"
PR = "r0"

require chirpstack-gateway-mesh.inc
require chirpstack-gateway-mesh-crates_${PV}.inc


# Copyright (c) 2025, Wifx SA <info@iot.wifx.net>
# All rights reserved.

SRCREV = "170a8abfdaf605cf65dcc46e480a65a8cdfb0be4"
SRC_URI += " \
    git://github.com/chirpstack/chirpstack-gateway-mesh.git;protocol=https;branch=master \
"
PR = "r0"

require chirpstack-gateway-mesh.inc
require chirpstack-gateway-mesh-crates_${PV}.inc


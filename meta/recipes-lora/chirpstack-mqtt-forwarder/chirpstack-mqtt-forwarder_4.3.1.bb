# Copyright (c) 2025, Wifx SA <info@iot.wifx.net>
# All rights reserved.

SRCREV = "955fc0040804483b12379a153c9670711feec336"
SRC_URI += " \
    git://github.com/chirpstack/chirpstack-mqtt-forwarder.git;protocol=https;branch=master \
"
PR = "r0"

require chirpstack-mqtt-forwarder.inc
require chirpstack-mqtt-forwarder-crates_${PV}.inc


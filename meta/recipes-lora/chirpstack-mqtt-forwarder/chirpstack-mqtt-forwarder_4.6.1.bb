# Copyright (c) 2025, Wifx SA <info@iot.wifx.net>
# All rights reserved.

SRCREV = "25ee84684a77b2cae160bc392d7f1d7e0fa0385b"
SRC_URI += " \
    git://github.com/chirpstack/chirpstack-mqtt-forwarder.git;protocol=https;branch=master \
"
PR = "r0"

require chirpstack-mqtt-forwarder.inc
require chirpstack-mqtt-forwarder-crates_${PV}.inc


# Copyright (c) 2025, Wifx SA <info@iot.wifx.net>
# All rights reserved.

SRCREV = "04e870b4af97bebb278ab29259941fd8b3aad72b"
SRC_URI += " \
    git://github.com/chirpstack/chirpstack-mqtt-forwarder.git;protocol=https;branch=master \
"
PR = "r0"

require chirpstack-mqtt-forwarder.inc
require chirpstack-mqtt-forwarder-crates_${PV}.inc


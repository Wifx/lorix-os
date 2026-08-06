# Copyright (c) 2025, Wifx SA <info@iot.wifx.net>
# All rights reserved.

SRC_URI += "git://github.com/brocaar/chirpstack-udp-forwarder.git;protocol=https;branch=master"
SRCREV = "1ff4549086b68c8bc45d274aebac87ed08b0626c"

PR = "r1"

require chirpstack-udp-forwarder.inc
require chirpstack-udp-forwarder-crates_${PV}.inc

# Copyright (c) 2025, Wifx SA <info@iot.wifx.net>
# All rights reserved.

SRC_URI += "git://github.com/brocaar/chirpstack-udp-bridge.git;protocol=https;branch=master"
SRCREV = "025b886fcc7bfc23aa6b0c5ee3f39e75909a10d6"

PR = "r1"

require chirpstack-udp-bridge.inc
require chirpstack-udp-bridge-crates_${PV}.inc

# Copyright (c) 2025, Wifx SA <info@iot.wifx.net>
# All rights reserved.

SRCREV = "188ef3d8f36065dca71ccc69ccc0deb0c1ce73c4"
SRC_URI += " \
    git://github.com/chirpstack/chirpstack.git;branch=master;protocol=https \
"

require chirpstack.inc
require chirpstack-crates_${PV}.inc

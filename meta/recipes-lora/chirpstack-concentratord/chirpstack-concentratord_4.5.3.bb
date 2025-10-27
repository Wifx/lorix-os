require chirpstack-concentratord.inc
require chirpstack-concentratord-crates_${PV}.inc

SRC_URI += " \
    git://github.com/brocaar/chirpstack-concentratord.git;protocol=https;branch=master \
    file://0001-vendor-Wifx-support.patch \
    file://0004-hal-receive-increase-RX-fifo-and-polling-time.patch \
"
SRCREV = "b69fef49df1923edc27b19fb2ae6deafd3e6f3e0"

PR = "r0"

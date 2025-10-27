require chirpstack-concentratord.inc
require chirpstack-concentratord-crates_${PV}.inc

SRC_URI += " \
    git://github.com/brocaar/chirpstack-concentratord.git;protocol=https;branch=master \
    file://0001-vendor-Wifx-support.patch \
    file://0004-hal-receive-increase-RX-fifo-and-polling-time.patch \
"
SRCREV = "f60f98f1d6c789cf60d49b1822570dca249a18eb"

PR = "r0"

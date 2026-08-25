require chirpstack-concentratord.inc
require chirpstack-concentratord-crates_${PV}.inc

SRC_URI += " \
    git://github.com/brocaar/chirpstack-concentratord.git;protocol=https;branch=master \
    file://0001-Update-LORIX-One-configuration-Add-Wifx-L1-configura.patch \
    file://0002-hal-receive-increase-RX-fifo-and-polling-time.patch \
    file://0003-Purge-expired-JIT-items-before-reporting-QueueFull.patch \
"
SRCREV = "b69fef49df1923edc27b19fb2ae6deafd3e6f3e0"

PR = "r1"

require chirpstack-concentratord-v4.inc


SRC_URI += " \
    git://github.com/brocaar/chirpstack-concentratord.git;protocol=https;branch=master \
    file://0001-vendor-LORIX-One-support-version-8XX-and-9XX.patch \
    file://0002-vendor-Wifx-L1-support-version-8XX-and-9XX.patch \
"
SRCREV = "d716f2c7a9deff6334b14be51f81f90ea643b78e"

PR = "r0"

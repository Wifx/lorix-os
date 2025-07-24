require chirpstack-concentratord-v4.inc


SRC_URI += " \
    git://github.com/brocaar/chirpstack-concentratord.git;protocol=https;branch=master \
    file://0001-vendor-LORIX-One-support-version-8XX-and-9XX.patch \
    file://0002-vendor-Wifx-L1-support-version-8XX-and-9XX.patch \
"
SRCREV = "f60f98f1d6c789cf60d49b1822570dca249a18eb"

PR = "r0"

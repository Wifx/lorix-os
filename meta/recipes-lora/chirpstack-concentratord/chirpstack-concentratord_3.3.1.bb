require chirpstack-concentratord.inc

SRC_URI += " \
    git://github.com/brocaar/chirpstack-concentratord.git;protocol=https;tag=v${PV} \
    file://0001-vendor-LORIX-One-support-version-863-870-and-902-928.patch \
    file://0002-vendor-Wifx-L1-support-version-863-870-and-902-928MH.patch \
"
PR = "r0"

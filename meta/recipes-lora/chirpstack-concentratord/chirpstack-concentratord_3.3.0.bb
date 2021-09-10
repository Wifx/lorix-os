require chirpstack-concentratord.inc

SRC_URI += " \
    git://github.com/brocaar/chirpstack-concentratord.git;protocol=git;tag=v${PV} \
    file://0001-add-lorix-one-support.patch \
    file://0002-Add-Wifx-L1-863-870-config.patch \
"
PR = "r1"

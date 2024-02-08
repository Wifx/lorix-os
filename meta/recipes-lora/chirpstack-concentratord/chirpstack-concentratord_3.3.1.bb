require chirpstack-concentratord.inc

LIC_FILES_CHKSUM = "file://LICENSE;md5=99e425257f8a67b7efd81dc0009ed8ff"

FILESEXTRAPATHS:prepend := "${THISDIR}/v3:"

SRC_URI += " \
    git://github.com/brocaar/chirpstack-concentratord.git;protocol=https;branch=master \
    file://0001-vendor-LORIX-One-support-version-863-870-and-902-928.patch \
    file://0002-vendor-Wifx-L1-support-version-863-870-and-902-928MH.patch \
"
SRCREV = "491450db7917c198360b923e93ae899c3445c201"

PR = "r0"

LICENSE = "BSD-2-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=2307fb28847883ac2b0b110b1c1f36e0"

require openrc.inc

PR = "0"
KBRANCH = "0.41.x"
SRCREV = "882c6bf3bcaba6903d9dc593f8ae41e505b4e4e7"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/${PN}-${PV}:"

SRC_URI += " \
    file://0001-mk-break-up-long-SED_REPLACE-line.patch \
    file://0002-fix-alternative-conf-and-init-dir-support.patch \
    file://0003-Modified-service-timeout-from-60-to-120-seconds.patch \
"

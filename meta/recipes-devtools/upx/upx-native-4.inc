DESCRIPTION = "The Ultimate Packer for eXecutables"
LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263"

S = "${WORKDIR}/git"
B = "${WORKDIR}/build"
do_configure[cleandirs] = "${B}"

inherit native
inherit cmake

EXTRA_OECMAKE = " \
"

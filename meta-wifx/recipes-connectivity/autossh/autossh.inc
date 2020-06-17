SUMMARY = "Automatically restart SSH sessions and tunnels"
DESCRIPTION = "autossh is a program to start a copy of ssh and monitor it, restarting it as necessary should it die or stop passing traffic. The idea is from rstunnel (Reliable SSH Tunnel), but implemented in C."
PROVIDES = "autossh"
LICENSE = "GPLv2+"

SRC_URI = "http://www.harding.motd.ca/autossh/${PN}-${PV}.tgz"

inherit autotools

S = "${WORKDIR}/${PN}-${PV}"
B = "${S}"
RDEPENDS_${PN} += "ssh"

TARGET_CC_ARCH += "${LDFLAGS}"

FILES_${PN}-doc += "${datadir}/examples"

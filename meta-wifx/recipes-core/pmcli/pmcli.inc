SUMMARY = "Process monitor Command Line Interface."
DESCRIPTION = "Start, stop, restart and manages others processes."
AUTHOR = "Wifx Sàrl"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=c6516b26d091c50b67e08602af287bfd"

RDEPENDS_${PN} += "pmonitor"

INSANE_SKIP_${PN} += "ldflags textrel"

SRC_URI += " \
    file://bash_completion \
"

S = "${WORKDIR}/git"
B = "${WORKDIR}/build"

inherit unpack-online-assets

do_install_base(){
    # Binary
    install -m 0755 -d ${D}${sbindir}
    install -m 0755 ${B}/pmcli ${D}${sbindir}/pmcli
    
    # Add bash completion file
    install -d ${D}${sysconfdir}/profile.d
    install -m 0644 ${WORKDIR}/bash_completion ${D}${sysconfdir}/profile.d/pmcli.sh
}

do_install() {
    do_install_base
}

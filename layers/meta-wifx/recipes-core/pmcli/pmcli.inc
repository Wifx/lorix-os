SUMMARY = "Process monitor Command Line Interface."
DESCRIPTION = "Start, stop, restart and manages others processes."
AUTHOR = "Wifx Sàrl"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://src/${GO_IMPORT}/LICENSE;md5=db3115a0626df58c65e3402d41fec1f7"
#LIC_FILES_CHKSUM = "file://LICENSE;md5=db3115a0626df58c65e3402d41fec1f7"

RDEPENDS_${PN} += "pmonitor"

SRC_URI += " \
    file://bash_completion \
"

GO_IMPORT = "git.wifx.net/pmonitor/pmcli"

S = "${WORKDIR}/git"
B = "${WORKDIR}/build"

inherit unpack-online-assets

do_install_base(){
    # Binary
    install -m 0755 -d ${D}${sbindir}
    install -m 0755 ${B}/bin/linux_arm/pmcli ${D}${sbindir}/pmcli
    #install -m 0755 ${B}/pmcli ${D}${sbindir}/pmcli
    
    # Add bash completion file
    install -d ${D}${sysconfdir}/profile.d
    install -m 0644 ${WORKDIR}/bash_completion ${D}${sysconfdir}/profile.d/pmcli.sh
}

do_install(){
    do_install_base
}

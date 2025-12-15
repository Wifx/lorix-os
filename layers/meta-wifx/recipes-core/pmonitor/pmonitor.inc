SUMMARY = "Process monitor service."
DESCRIPTION = "Process monitor service, start, stop, restart and manages others processes."
AUTHOR = "Wifx SA"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://src/${GO_IMPORT}/LICENSE;md5=a971c6e63e2a5a8d56f539855996ed37"

CVE_PRODUCT = "wifx:pmonitor"

inherit upx
UPX_COMPRESS_FILES:${PN} = "${sbindir}/pmonitord"

RDEPENDS:${PN} += "pvisor glibc"
RRECOMMENDS:${PN} += "pmcli"

SRC_URI += " \
    file://config.yml \
    file://net.wifx.pmonitor.conf \
"

GO_IMPORT = "git.wifx.net/pmonitor/pmonitord"

S = "${WORKDIR}/git"
B = "${WORKDIR}/build"

inherit unpack-online-assets useradd

do_install_base(){
    # Configuration file
    install -m 0755 -d ${D}${sysconfdir}/pmonitor
    install -m 0644 ${WORKDIR}/config.yml ${D}${sysconfdir}/pmonitor/config.yml

    # Monitor binary
    install -m 0755 -d ${D}${sbindir}
    install -m 0755 ${B}/bin/linux_arm/pmonitord ${D}${sbindir}/pmonitord

    # D-bus configuration
    install -m 0755 -d ${D}${sysconfdir}/dbus-1/system.d
    install -m 0644 ${WORKDIR}/net.wifx.pmonitor.conf ${D}${sysconfdir}/dbus-1/system.d/net.wifx.pmonitor.conf
}

do_install(){
    do_install_base
}

# Add pmctl group
USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM:${PN} = "-r pmctl"

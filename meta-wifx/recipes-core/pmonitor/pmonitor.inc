SUMMARY = "Process monitor service."
DESCRIPTION = "Process monitor service, start, stop, restart and manages others processes."
AUTHOR = "Wifx Sàrl"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=c6516b26d091c50b67e08602af287bfd"

RDEPENDS_${PN} += "pvisor pmcli glibc"

SRC_URI += " \
    file://config.yml \
    file://net.wifx.pmonitor.conf \
"

S = "${WORKDIR}/git"
B = "${WORKDIR}/build"

INSANE_SKIP_${PN} += "ldflags textrel"

inherit unpack-online-assets useradd

do_install_base(){
    # Configuration file
    install -m 0755 -d ${D}${sysconfdir}/pmonitor
    install -m 0644 ${WORKDIR}/config.yml ${D}${sysconfdir}/pmonitor/config.yml

    # Monitor binary
    install -m 0755 -d ${D}${sbindir}
    install -m 0755 ${B}/pmonitor ${D}${sbindir}/pmonitord

    # D-bus configuration
    install -m 0755 -d ${D}${sysconfdir}/dbus-1/system.d
    install -m 0644 ${WORKDIR}/net.wifx.pmonitor.conf ${D}${sysconfdir}/dbus-1/system.d/net.wifx.pmonitor.conf
}

do_install() {
    do_install_base
}

# Add pmctl group
USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM_${PN} = "-r pmctl"

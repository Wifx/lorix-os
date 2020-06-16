SUMMARY = "Process supervisor, small/efficiant process to be used with pmonitord"
DESCRIPTION = "The pvisor is the process supervisor which is launched with every process to be monitored by the pmonitor daemon."
AUTHOR = "Wifx Sàrl"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=db3115a0626df58c65e3402d41fec1f7"

S = "${WORKDIR}/git"

inherit unpack-online-assets

do_install() {
    install -m 0755 -d ${D}${sbindir}
    install -m 0755 ${S}/work/bin/pvisor ${D}${sbindir}/pvisor
}

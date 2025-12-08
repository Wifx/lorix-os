SUMMARY = "NetworkManager connection profiles"
AUTHOR = "Wifx SA"
SECTION = "base"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=c6344409be0a6b4950e1b252c4b44559"

SRC_URI = " \
    file://LICENSE \
    file://backhaul.nmconnection \
    file://service.nmconnection \
    file://wwan.nmconnection \
"

PR = "r0"
S = "${WORKDIR}"

INHIBIT_DEFAULT_DEPS = "1"
do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    # Install default connections and main configuration file
    install -d ${D}${sysconfdir}/NetworkManager/system-connections
    install -m 0600 ${WORKDIR}/service.nmconnection ${D}${sysconfdir}/NetworkManager/system-connections
    install -m 0600 ${WORKDIR}/backhaul.nmconnection ${D}${sysconfdir}/NetworkManager/system-connections
    install -m 0600 ${WORKDIR}/wwan.nmconnection ${D}${sysconfdir}/NetworkManager/system-connections
}

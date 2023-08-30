SUMMARY = "NetworkManager machine related scripts"
AUTHOR = "Wifx Sàrl"
SECTION = "base"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=d166218d6256cab6058ea8e31a8b66e8"

SRC_URI = " \
    file://LICENSE \
    file://backhaul.nmconnection \
    file://service.nmconnection \
    file://NetworkManager.state \
"

PR = "r0"
S = "${WORKDIR}"

INHIBIT_DEFAULT_DEPS = "1"
do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"

RDEPENDS_${PN} += "bash networkmanager ${@bb.utils.contains('MACHINE_FEATURES','wwan','machine-wwan modemmanager','',d)}"

do_install() {
    # Install default connections and main configuration file
    install -d ${D}${sysconfdir}/NetworkManager/system-connections
    install -m 0600 ${WORKDIR}/service.nmconnection ${D}${sysconfdir}/NetworkManager/system-connections
    install -m 0600 ${WORKDIR}/backhaul.nmconnection ${D}${sysconfdir}/NetworkManager/system-connections

    # Install general state parameters
    install -m 700 -d ${D}/var/lib/NetworkManager
    install -m 644 ${WORKDIR}/NetworkManager.state ${D}/var/lib/NetworkManager/NetworkManager.state

    if [ "${@bb.utils.contains('MACHINE_FEATURES','wwan','1','0',d)}" = "1" ] ; then
        sed -i -e 's,WWANEnabled=false,WWANEnabled=true,g' \
           ${D}/var/lib/NetworkManager/NetworkManager.state
    fi
}

PACKAGE_ARCH = "${MACHINE_ARCH}"

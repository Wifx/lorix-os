SUMMARY = "ChirpStack concentratord/UDP Forwarder package/Helium Gateway"
DESCRIPTION = "Configuration setup for interfacing the ChirpStack Concentratord with the Chripstack UDP Forwarder and the Helium Gateway forwarder."
AUTHOR = "Wifx Sàrl"
SECTION = "base"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=83564c4ad755d0edeaa1ba4b3918b365"

RDEPENDS:${PN} += " \
    pmonitor \
    chirpstack-concentratord \
    chirpstack-udp-forwarder \
    helium-gateway \
"

SRC_URI = " \
    file://LICENSE \
    file://helium-csuf-concentratord.yml \
    file://20-servers.toml \
"

S = "${WORKDIR}"

INHIBIT_DEFAULT_DEPS = "1"
do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"

inherit pmonitor

do_install() {

    install -d ${D}/etc/opt/helium-gateway/chirpstack-udp-forwarder
    install ${WORKDIR}/20-servers.toml ${D}/etc/opt/helium-gateway/chirpstack-udp-forwarder/20-servers.toml

    # Pmonitor service configuration files
    pmonitor_service_install ${WORKDIR}/helium-csuf-concentratord.yml
}

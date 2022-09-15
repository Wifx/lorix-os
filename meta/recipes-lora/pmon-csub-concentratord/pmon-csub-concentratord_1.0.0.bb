SUMMARY = "ChirpStack concentratord/UDP bridge package"
DESCRIPTION = "Configuration setup for interfacing the ChirpStack Concentratord with the Chripstack UDP Bridge."
AUTHOR = "Wifx Sàrl"
SECTION = "base"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=83564c4ad755d0edeaa1ba4b3918b365"

RDEPENDS_${PN} += " \
    pmonitor \
    chirpstack-concentratord \
    chirpstack-udp-bridge \
"

SRC_URI = " \
    file://LICENSE \
    file://csub-concentratord.yml \
"

RPROVIDES_${PN} += "virtual/udp-packet-forwarder"

S = "${WORKDIR}"

INHIBIT_DEFAULT_DEPS = "1"
do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"

inherit pmonitor

do_install() {
    # Pmonitor service configuration files
    pmonitor_service_install ${WORKDIR}/csub-concentratord.yml
}

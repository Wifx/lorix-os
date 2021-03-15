SUMMARY = "ChirpStack concentratord/UDP bridge package"
DESCRIPTION = "Configuration setup for interfacing the ChirpStack Cocnentratord with the Chripstack UDP Bridge."
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
    file://chirpstack-concentratord-udp.yml \
"

S = "${WORKDIR}"

INHIBIT_DEFAULT_DEPS = "1"
do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"

inherit pmonitor

CONF_DIR = "${sysconfoptdir}/chirpstack-gateway-bridge"

do_install() {
    # Pmonitor service configuration files
    pmonitor_service_install ${WORKDIR}/chirpstack-concentratord-udp.yml
}

CONFFILES_${PN} += " \
    ${CONF_DIR}/chirpstack-concentratord-udp.toml \
"

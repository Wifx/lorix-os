SUMMARY = "ChirpStack Gateway Bridge/ChirpStack Concentratord package"
DESCRIPTION = "Configuration setup for interfacing the ChirpStack Gateway Bridge with the ChirpStack Concentratord."
AUTHOR = "Wifx Sàrl"
SECTION = "base"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=83564c4ad755d0edeaa1ba4b3918b365"

RDEPENDS_${PN} += " \
    pmonitor \
    chirpstack-gateway-bridge \
    chirpstack-concentratord \
"

SRC_URI = " \
    file://LICENSE \
    file://csgb-concentratord.yml \
    file://chirpstack-gateway-bridge_conf.toml \
"

S = "${WORKDIR}"

INHIBIT_DEFAULT_DEPS = "1"
do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"

inherit pmonitor

CONF_DIR = "${sysconfoptdir}/chirpstack-gateway-bridge"

do_install() {

    install -d ${D}${CONF_DIR}
    install -m 0644 ${WORKDIR}/chirpstack-gateway-bridge_conf.toml ${D}${CONF_DIR}/chirpstack-gateway-bridge-concentratord.toml


    # Pmonitor service configuration files
    pmonitor_service_install ${WORKDIR}/csgb-concentratord.yml
}

CONFFILES_${PN} += " \
    ${CONF_DIR}/chirpstack-gateway-bridge-concentratord.toml \
"

SUMMARY = "ChirpStack MQTT Forwarder/ChirpStack Concentratord package"
DESCRIPTION = "Configuration setup for interfacing the ChirpStack MQTT Forwarder with the ChirpStack Concentratord."
AUTHOR = "Wifx SA"
SECTION = "base"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=ac08f2eed56d2f4b41ce86b963832f5c"

RDEPENDS:${PN} += " \
    pmonitor \
    chirpstack-mqtt-forwarder \
    chirpstack-concentratord \
    chirpstack-gateway-mesh \
"

SRC_URI = " \
    file://LICENSE \
    file://csmf-concentratord.yml \
"

S = "${WORKDIR}"

INHIBIT_DEFAULT_DEPS = "1"
do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"

inherit pmonitor

do_install() {

    # Pmonitor service configuration files
    pmonitor_service_install ${WORKDIR}/csmf-concentratord.yml
}

SUMMARY = "ChirpStack LNS + ChirpStack MQTT Forwarder + concentratord"
AUTHOR = "Wifx SA"
SECTION = "base"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=ac08f2eed56d2f4b41ce86b963832f5c"

RDEPENDS:${PN} += " \
    chirpstack \
    chirpstack-mqtt-forwarder \
    chirpstack-concentratord \
    redis \
    pmonitor \
    mosquitto \
"

SRC_URI = " \
    file://LICENSE \
    file://chirpstack-elns.yml \
"

S = "${WORKDIR}"

INHIBIT_DEFAULT_DEPS = "1"
do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"

inherit pmonitor

do_install() {
    # Pmonitor service configuration files
    pmonitor_service_install ${WORKDIR}/chirpstack-elns.yml
}

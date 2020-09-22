SUMMARY = "ChirpStack Gateway Bridge/UDP packet forwarder package"
DESCRIPTION = "Configuration setup for interfacing the ChirpStack Gateway Bridge with the UDP packet forwarder."
AUTHOR = "Wifx Sàrl"
SECTION = "base"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=83564c4ad755d0edeaa1ba4b3918b365"

RDEPENDS_${PN} += " \
    pmonitor \
    chirpstack-gateway-bridge \
    udp-packet-forwarder \
"

SRC_URI = " \
    file://LICENSE \
    file://chirpstack-gateway-bridge_conf.toml \
    file://chirpstack-gateway-bridge-udp.yml \
    file://gateway_global_conf.json \
    file://gateway_local_conf.json \
"

S = "${WORKDIR}"

INHIBIT_DEFAULT_DEPS = "1"
do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"

inherit pmonitor

CONF_DIR = "${sysconfoptdir}/chirpstack-gateway-bridge"
UPF_CONF_DIR = "${sysconfoptdir}/udp-packet-forwarder/gateway/chirpstack-gateway-bridge"

do_install() {
    # Install ChirpStack Gateway Bridge configuration file (UDP packet forwarder)
    install -d ${D}${CONF_DIR}
    install -m 0644 ${WORKDIR}/chirpstack-gateway-bridge_conf.toml ${D}${CONF_DIR}/chirpstack-gateway-bridge.toml

    # UDP packet forwarder configuration
    install -m 0755 -d ${D}${UPF_CONF_DIR}
    install -m 0644 -D "${WORKDIR}/gateway_global_conf.json" "${D}${UPF_CONF_DIR}/"
    install -m 0644 -D "${WORKDIR}/gateway_local_conf.json" "${D}${UPF_CONF_DIR}/"

    # Pmonitor service configuration files
    pmonitor_service_install ${WORKDIR}/chirpstack-gateway-bridge-udp.yml
}

CONFFILES_${PN} += " \
    ${CONF_DIR}/chirpstack-gateway-bridge.toml \
    ${UPF_CONF_DIR}/gateway_global_conf.json \
    ${UPF_CONF_DIR}/gateway_local_conf.json \
    "

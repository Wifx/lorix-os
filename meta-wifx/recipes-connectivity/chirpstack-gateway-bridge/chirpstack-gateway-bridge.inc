DESCRIPTION = "ChirpStack Gateway Bridge"
HOMEPAGE = "https://www.chirpstack.io/"
PRIORITY = "optional"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://src/${GO_IMPORT}/LICENSE;md5=99e425257f8a67b7efd81dc0009ed8ff"

SRCTAG = "v${PV}"
SRC_URI += " \
    git://github.com/brocaar/chirpstack-gateway-bridge.git;protocol=git;tag=${SRCTAG} \
    file://conf.toml \
    file://chirpstack-gateway-bridge-udp.yml \
    file://udp-packet-forwarder/gateway_global_conf.json \
    file://udp-packet-forwarder/gateway_local_conf.json \
"

inherit go-mod pmonitor

S = "${WORKDIR}/git"

GO_IMPORT = "github.com/brocaar/chirpstack-gateway-bridge"

BIN_DIR = "${optdir}/chirpstack-gateway-bridge"
CONF_DIR = "${sysconfoptdir}/chirpstack-gateway-bridge"
UPF_CONF_DIR = "${sysconfoptdir}/udp-packet-forwarder/gateway/chirpstack-gateway-bridge"

GO_EXTRA_LDFLAGS = "-X main.version=${PV}"

do_install() {
    install -d ${D}${BIN_DIR}
    install -m 0755 "${B}/${GO_BUILD_BINDIR}/chirpstack-gateway-bridge" ${D}${BIN_DIR}/

    install -d ${D}${CONF_DIR}
    install -m 0644 ${WORKDIR}/conf.toml ${D}${CONF_DIR}/chirpstack-gateway-bridge.toml

    # UDP packet forwarder configuration
    install -m 0755 -d ${D}${UPF_CONF_DIR}
    install -m 0644 -D "${WORKDIR}/udp-packet-forwarder/gateway_global_conf.json" "${D}${UPF_CONF_DIR}/"
    install -m 0644 -D "${WORKDIR}/udp-packet-forwarder/gateway_local_conf.json" "${D}${UPF_CONF_DIR}/"

    # Pmonitor service configuration files
    pmonitor_service_install ${WORKDIR}/chirpstack-gateway-bridge-udp.yml
}

FILES_${PN} += "${BIN_DIR}"
FILES_${PN}-dbg += "${BIN_DIR}/.debug"

CONFFILES_${PN} += "${CONF_DIR}/chirpstack-gateway-bridge.toml"

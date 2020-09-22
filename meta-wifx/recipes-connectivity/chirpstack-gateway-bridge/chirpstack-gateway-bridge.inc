DESCRIPTION = "ChirpStack Gateway Bridge"
HOMEPAGE = "https://www.chirpstack.io/"
PRIORITY = "optional"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=99e425257f8a67b7efd81dc0009ed8ff"

SRCTAG = "v${PV}"
SRC_URI += " \
    git://github.com/brocaar/chirpstack-gateway-bridge.git;protocol=git;tag=${SRCTAG} \
"
#file://chirpstack-gateway-bridge-concentratord.yml \
#file://conf-concentratord.toml

RDEPENDS_${PN} += "virtual/lora-packet-forwarder"

inherit gomod

S = "${WORKDIR}/git"

GO_SRC = "${S}/cmd/chirpstack-gateway-bridge"

BIN_DIR = "${optdir}/chirpstack-gateway-bridge"
#CONF_DIR = "${sysconfoptdir}/chirpstack-gateway-bridge"
#UPF_CONF_DIR = "${sysconfoptdir}/udp-packet-forwarder/gateway/chirpstack-gateway-bridge"

GO_EXTRA_LDFLAGS = "-X main.version=${PV}"

do_install() {
    install -d ${D}${BIN_DIR}
    install -m 0755 "${B}/chirpstack-gateway-bridge" ${D}${BIN_DIR}/

    #install -d ${D}${CONF_DIR}
    #install -m 0644 ${WORKDIR}/conf-udp.toml ${D}${CONF_DIR}/chirpstack-gateway-bridge-udp.toml
    #install -m 0644 ${WORKDIR}/conf-concentratord.toml ${D}${CONF_DIR}/chirpstack-gateway-bridge-concentratord.toml

    # Pmonitor service configuration files
    #pmonitor_service_install ${WORKDIR}/chirpstack-gateway-bridge-concentratord.yml
}

FILES_${PN} += "${BIN_DIR}"
FILES_${PN}-dbg += "${BIN_DIR}/.debug"
#CONFFILES_${PN} += "${CONF_DIR}/chirpstack-gateway-bridge-udp.toml"
#CONFFILES_${PN} += "${CONF_DIR}/chirpstack-gateway-bridge-concentratord.toml"
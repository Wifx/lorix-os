DESCRIPTION = "ChirpStack Packet Multiplexer"
HOMEPAGE = "https://www.chirpstack.io/"
PRIORITY = "optional"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://src/${GO_IMPORT}/LICENSE;md5=5301050fd7cd58850085239d559297be"

SRCTAG = "v${PV}"
SRC_URI += " \
    git://github.com/brocaar/chirpstack-packet-multiplexer.git;protocol=https;tag=${SRCTAG} \
    file://conf.toml \
    file://upf-multiplexer.yml \
"

RDEPENDS_${PN} += "udp-packet-forwarder pmcli"

inherit go-mod pmonitor

S = "${WORKDIR}/git"

GO_IMPORT = "github.com/brocaar/chirpstack-packet-multiplexer"

BIN_DIR = "${optdir}/chirpstack-packet-multiplexer"
CONF_DIR = "${sysconfoptdir}/chirpstack-packet-multiplexer"
UPF_CONF_DIR = "${sysconfoptdir}/udp-packet-forwarder/gateway/chirpstack-packet-multiplexer"

GO_EXTRA_LDFLAGS = "-X main.version=${PV}"

do_install() {
    install -d ${D}${BIN_DIR}
    install -m 0755 "${B}/${GO_BUILD_BINDIR}/chirpstack-packet-multiplexer" ${D}${BIN_DIR}/

    install -d ${D}${CONF_DIR}
    install -m 0644 ${WORKDIR}/conf.toml ${D}${CONF_DIR}/chirpstack-packet-multiplexer.toml

    # Pmonitor service configuration files
    pmonitor_service_install ${WORKDIR}/upf-multiplexer.yml
}

FILES_${PN} += "${BIN_DIR}"
FILES_${PN}-dbg += "${BIN_DIR}/.debug"

CONFFILES_${PN} += "${CONF_DIR}/chirpstack-packet-multiplexer.toml"

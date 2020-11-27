DESCRIPTION = "ChirpStack Gateway Bridge"
HOMEPAGE = "https://www.chirpstack.io/"
PRIORITY = "optional"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://src/${GO_IMPORT}/LICENSE;md5=99e425257f8a67b7efd81dc0009ed8ff"

SRCTAG = "v${PV}"
SRC_URI += " \
    git://github.com/brocaar/chirpstack-gateway-bridge.git;protocol=git;tag=${SRCTAG} \
"

inherit go-mod

S = "${WORKDIR}/git"

GO_IMPORT = "github.com/brocaar/chirpstack-gateway-bridge"

BIN_DIR = "${optdir}/chirpstack-gateway-bridge"

GO_EXTRA_LDFLAGS = "-X main.version=${PV}"

do_install() {
    install -d ${D}${BIN_DIR}
    install -m 0755 "${B}/${GO_BUILD_BINDIR}/chirpstack-gateway-bridge" ${D}${BIN_DIR}/
}

FILES_${PN} += "${BIN_DIR}"
FILES_${PN}-dbg += "${BIN_DIR}/.debug"

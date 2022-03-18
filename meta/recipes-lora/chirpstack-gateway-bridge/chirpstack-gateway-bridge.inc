DESCRIPTION = "ChirpStack Gateway Bridge"
HOMEPAGE = "https://www.chirpstack.io/"
PRIORITY = "optional"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=99e425257f8a67b7efd81dc0009ed8ff"

SRCTAG = "v${PV}"
SRC_URI += " \
    git://github.com/brocaar/chirpstack-gateway-bridge.git;protocol=https;tag=${SRCTAG} \
    file://0001-multiple-config-files.patch \
    file://backend_concentratord.toml \
    file://backend_semtech-udp.toml \
    file://filters.toml \
    file://general.toml \
    file://integration.toml \
"

inherit goarch

CONF_DIR = "${sysconfoptdir}/chirpstack-gateway-bridge"
S = "${WORKDIR}/git"

DEPENDS = "go-native"

# Make sure that make runs one job at a time.
PARALLEL_MAKE = ""

export GOOS = "${TARGET_GOOS}"
export GOARCH = "${TARGET_GOARCH}"
export GOARM = "${TARGET_GOARM}"
export GOCACHE = "${WORKDIR}/go/cache"
export HOME = "${WORKDIR}"

do_configure[noexec] = "1"

do_compile() {
    oe_runmake

    # Clear the modcache. go mod sets the permissions such that yocto will
    # raise permission errors when cleaning up the directory.
    go clean -modcache
}

do_install() {
    install -d ${D}${optdir}/chirpstack-gateway-bridge
    install -m 0755 "${S}/build/chirpstack-gateway-bridge" ${D}${optdir}/chirpstack-gateway-bridge

    install_configs
}

install_configs() {
    install -m 0755 -d ${D}${CONF_DIR}

    install_config general.toml                         10-general.toml
    install_config backend_semtech-udp.toml             20-backend_semtech-udp.toml
    install_config backend_concentratord.toml           20-backend_concentratord.toml
    install_config integration.toml                     30-integration.toml
    install_config filters.toml                         40-filters.toml
}

install_config() {
    if [ -z "$1" ] || [ -z "$2"]; then
        bbfatal "Usage install_config <source> [dest]"
    fi

    install -m 0644 ${WORKDIR}/$1 ${D}${CONF_DIR}/$2
}


INSANE_SKIP_${PN} = "already-stripped"

FILES_${PN} += " \
    ${optdir} \
    ${CONF_DIR}/ \
"

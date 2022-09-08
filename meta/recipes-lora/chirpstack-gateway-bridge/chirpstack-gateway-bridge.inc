DESCRIPTION = "ChirpStack Gateway Bridge"
HOMEPAGE = "https://www.chirpstack.io/"
PRIORITY = "optional"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=99e425257f8a67b7efd81dc0009ed8ff"

SRCTAG = "v${PV}"
SRC_URI += " \
    git://github.com/chirpstack/chirpstack-gateway-bridge.git;branch=v3;protocol=https;tag=${SRCTAG} \
    file://0001-multiple-config-files.patch \
    file://10-general.toml \
    file://20-backend_semtech-udp.toml \
    file://20-backend_concentratord.toml \
    file://30-integration.toml \
    file://40-filters.toml \
    file://50-metrics.toml \
    file://60-metadata.toml \
    file://70-commands.toml \
    file://99-custom.toml \
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

    go mod tidy

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

    install_config 10-general.toml
    install_config 20-backend_semtech-udp.toml
    install_config 20-backend_concentratord.toml
    install_config 30-integration.toml
    install_config 40-filters.toml
    install_config 50-metrics.toml
    install_config 60-metadata.toml
    install_config 70-commands.toml
    install_config 99-custom.toml
}

install_config() {
    if [ -z "$1" ]; then
        bbfatal "Usage install_config <source> [dest]"
    fi

    SRC_FILE=$1

    if [ -z "$2" ]; then
        DST_FILE=$1
    else
        DST_FILE=$2
    fi

    install -m 0644 ${WORKDIR}/$SRC_FILE ${D}${CONF_DIR}/$DST_FILE
}


INSANE_SKIP_${PN} = "already-stripped"

FILES_${PN} += " \
    ${optdir} \
    ${CONF_DIR}/ \
"

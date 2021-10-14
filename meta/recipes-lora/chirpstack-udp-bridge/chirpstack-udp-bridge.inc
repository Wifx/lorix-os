HOMEPAGE = "https://www.chirpstack.io/"
DESCRIPTION = "ChirpStack UDP Bridge"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=09fe2246a30dca84af09ac8608093cd7"

SRC_URI += "\
    file://0001-multiple-config-files.patch \
    file://00-concentratord.toml \
    file://10-udp-bridge.toml \
    file://20-servers.toml \
"

DEPENDS += " \
    clang-native \
"

inherit cargo

CONF_DIR = "${sysconfoptdir}/chirpstack-udp-bridge"
S = "${WORKDIR}/git"

export BINDGEN_EXTRA_CLANG_ARGS="-I${STAGING_INCDIR}"

do_install() {

    if [ "${CARGO_BUILD_TYPE}" = "--release" ]; then
        local cargo_bindir="${CARGO_RELEASE_DIR}"
    else
        local cargo_bindir="${CARGO_DEBUG_DIR}"
    fi

    # Configuration
    install -m 0755 -d ${D}${CONF_DIR}
    install_config 00-concentratord.toml
    install_config 10-udp-bridge.toml
    install_config 20-servers.toml
    
    # Bin directory
    install -m 0755 -d ${D}${optdir}/chirpstack-udp-bridge
    install -m 0755 ${cargo_bindir}/chirpstack-udp-bridge ${D}${optdir}/chirpstack-udp-bridge/chirpstack-udp-bridge
}

install_config() {
    if [ -z "$1" ]; then
        bbfatal "Usage install_config <source> [dest]"
    fi

    if [ -z "$2"]; then
        DEST=$1
    else
        DEST=$2
    fi

    install -m 0644 ${WORKDIR}/$1 ${D}${CONF_DIR}/${DEST}
}

FILES_${PN} += " \
    ${CONF_DIR}/udp-bridge.toml \
    ${optdir}/chirpstack-udp-bridge/chirpstack-udp-bridge \
"

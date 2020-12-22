HOMEPAGE = "https://www.chirpstack.io/"
DESCRIPTION = "ChirpStack UDP Bridge"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=09fe2246a30dca84af09ac8608093cd7"

SRC_URI += "\
    file://udp-bridge.toml \
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

    install -m 0755 -d ${D}${CONF_DIR}
    install_config udp-bridge.toml udp-bridge.toml
    
    # Bin directory
    install -m 0755 -d ${D}${optdir}/chirpstack-udp-bridge
    install -m 0644 ${cargo_bindir}/chirpstack-udp-bridge ${D}${optdir}/chirpstack-udp-bridge/chirpstack-udp-bridge
}

install_config() {
    if [ -z "$1" ] || [ -z "$2"]; then
        bbfatal "Usage install_config <source> [dest]"
    fi

    install -m 0644 ${WORKDIR}/$1 ${D}${CONF_DIR}/$2
}

FILES_${PN} += " \
    ${CONF_DIR}/udp-bridge.toml \
    ${optdir}/chirpstack-udp-bridge/chirpstack-udp-bridge \
"

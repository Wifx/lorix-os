# Copyright (c) 2025, Wifx SA <info@iot.wifx.net>
# All rights reserved.

HOMEPAGE = "https://www.chirpstack.io/"
DESCRIPTION = "ChirpStack UDP Bridge"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=09fe2246a30dca84af09ac8608093cd7"

SRC_URI += "\
    file://0001-Ignore-trailing-null-bytes-on-downlink-packet.patch \
    file://0002-No-null-in-json.patch \
    file://0003-Update-Prometheus-crate-version-to-fix-build-with-ca.patch \
    file://00-concentratord.toml \
    file://10-udp-bridge.toml \
    file://20-servers.toml \
"

UPX_COMPRESS_FILES:${PN} = "/opt/chirpstack-udp-bridge/chirpstack-udp-bridge"
inherit upx

DEPENDS += " \
    protobuf-native \
    clang-native \
    protobuf \
    cmake-native \
"

## meta-rust
inherit cargo cargo-update-recipe-crates

# Fix panic static and configure options (SQLite based)
RUST_PANIC_STRATEGY = "abort"

# Remove TMPDIR reference in C based crates
DEBUG_PREFIX_MAP:append = " \
    -fmacro-prefix-map=${WORKDIR}=/usr/src/debug/${PN}/${EXTENDPE}${PV}-${PR} \
    -fdebug-prefix-map=${WORKDIR}=/usr/src/debug/${PN}/${EXTENDPE}${PV}-${PR} \
"

export BINDGEN_EXTRA_CLANG_ARGS="-I${STAGING_INCDIR}"

CONF_DIR = "${sysconfoptdir}/chirpstack-udp-bridge"
S = "${WORKDIR}/git"

do_install() {
    # Configuration
    install -m 0755 -d ${D}${CONF_DIR}
    install_config 00-concentratord.toml
    install_config 10-udp-bridge.toml
    install_config 20-servers.toml

    # Bin directory
    install -m 0755 -d ${D}${optdir}/chirpstack-udp-bridge
    install -m 0755 ${B}/target/${CARGO_TARGET_SUBDIR}/chirpstack-udp-bridge ${D}${optdir}/chirpstack-udp-bridge/chirpstack-udp-bridge
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

FILES:${PN} += " \
    ${CONF_DIR}/udp-bridge.toml \
    ${optdir}/chirpstack-udp-bridge/chirpstack-udp-bridge \
"

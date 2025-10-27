# Copyright (c) 2025, Wifx SA <info@iot.wifx.net>
# All rights reserved.

HOMEPAGE = "https://www.chirpstack.io/"
DESCRIPTION = "ChirpStack UDP Forwarder"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=bc4546f147d6f9892ca1b7d23bf41196"

SRC_URI += "\
    file://0001-Ignore-trailing-null-bytes-on-downlink-packet.patch \
    file://00-concentratord.toml \
    file://10-udp-forwarder.toml \
    file://20-servers.toml \
"

inherit upx
UPX_COMPRESS_FILES:${PN} = "${optdir}/chirpstack-udp-forwarder/chirpstack-udp-forwarder"

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

do_fix_strip() {
    # This is not the sources's job to strip binaries as Yocto does it very well
    # and allow to keep unstripped binaries in ${PN}-dev pkg.
    sed -i "s/strip = true/strip = false/" ${S}/Cargo.toml
}
addtask fix_strip after do_patch before do_configure

export BINDGEN_EXTRA_CLANG_ARGS="-I${STAGING_INCDIR}"

CONF_DIR = "${sysconfoptdir}/chirpstack-udp-forwarder"
S = "${WORKDIR}/git"

do_install() {
    # Configuration
    install -m 0755 -d ${D}${CONF_DIR}
    install_config 00-concentratord.toml
    install_config 10-udp-forwarder.toml
    install_config 20-servers.toml

    # Bin directory
    install -m 0755 -d ${D}${optdir}/chirpstack-udp-forwarder
    install -m 0755 ${B}/target/${CARGO_TARGET_SUBDIR}/chirpstack-udp-forwarder ${D}${optdir}/chirpstack-udp-forwarder/chirpstack-udp-forwarder
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
    ${CONF_DIR}/udp-forwarder.toml \
    ${optdir}/chirpstack-udp-forwarder/chirpstack-udp-forwarder \
"

# Copyright (c) 2025, Wifx SA <info@iot.wifx.net>
# All rights reserved.

DESCRIPTION = "ChirpStack Gateway Mesh"
HOMEPAGE = "https://www.chirpstack.io/"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=070df97663cffadabf677115eb41db93"

SRC_URI += "\
    file://10-logging.toml \
    file://20-mesh.toml \
    file://21-mesh-proxy-api.toml \
    file://30-backend.toml \
    file://40-events.toml \
    file://50-commands.toml \
    file://mappings/AS923.toml \
    file://mappings/AS923_2.toml \
    file://mappings/AS923_3.toml \
    file://mappings/AS923_4.toml \
    file://mappings/AU915.toml \
    file://mappings/EU868.toml \
    file://mappings/IN865.toml \
    file://mappings/KR920.toml \
    file://mappings/RU864.toml \
    file://mappings/US915.toml \
"

UPX_COMPRESS_FILES:${PN} = "/opt/chirpstack-gateway-mesh/chirpstack-gateway-mesh"
inherit upx

CONF_DIR = "${sysconfoptdir}/chirpstack-gateway-mesh"
S = "${WORKDIR}/git"

# Required to build chirpstack_api
DEPENDS = " \
    protobuf-native \
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

do_install() {
    # Configuration
    install -m 0755 -d ${D}${CONF_DIR}
    install_config 10-logging.toml
    install_config 20-mesh.toml
    install_config 21-mesh-proxy-api.toml
    install_config 30-backend.toml
    install_config 40-events.toml
    install_config 50-commands.toml

    install_mappings

    # Bin directory
    install -m 0755 -d ${D}${optdir}/chirpstack-gateway-mesh
    install -m 0755 ${B}/target/${CARGO_TARGET_SUBDIR}/chirpstack-gateway-mesh ${D}${optdir}/chirpstack-gateway-mesh/chirpstack-gateway-mesh
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


install_mappings() {
    install -m 0755 -d ${D}${CONF_DIR}/mappings
    install_mapping AS923.toml
    install_mapping AS923_2.toml
    install_mapping AS923_3.toml
    install_mapping AS923_4.toml
    install_mapping AU915.toml
    install_mapping EU868.toml
    install_mapping IN865.toml
    install_mapping KR920.toml
    install_mapping RU864.toml
    install_mapping US915.toml
}

install_mapping() {
    if [ -z "$1" ]; then
        bbfatal "Usage install_mapping <source> [dest]"
    fi

    install -m 0644 ${WORKDIR}/mappings/$1 ${D}${CONF_DIR}/mappings/$1
}

FILES:${PN} += " \
    ${optdir}/chirpstack-gateway-mesh/chirpstack-gateway-mesh \
    ${CONF_DIR} \
"

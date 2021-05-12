HOMEPAGE = "https://www.helium.com/"
DESCRIPTION = "Helium Gateway"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=1c3a461cb3bfa8dedcbf13b9e8a6335a"

SRC_URI += "\
    file://default.toml \
    file://000-remove-cargo-strip.patch \
    file://001-target-valid-trait-elliptic-curve.patch \
"

inherit cargo

DEPENDS += " \
    clang-native \
    cmake-native \
    protobuf-c protobuf-c-native \
"

ASSUME_PROVIDED_remove = "cmake-native"

CONF_DIR = "${sysconfoptdir}/helium-gateway"
S = "${WORKDIR}/git"

do_install() {

    if [ "${CARGO_BUILD_TYPE}" = "--release" ]; then
        local cargo_bindir="${CARGO_RELEASE_DIR}"
    else
        local cargo_bindir="${CARGO_DEBUG_DIR}"
    fi

    # Config
    instal -m 0664 default.toml $CONF_DIR/default.toml

    # Bin directory
    install -m 0775 -d ${D}${optdir}/helium-gateway
    install -m 0777 ${cargo_bindir}/helium_gateway ${D}${optdir}/helium-gateway/helium-gateway

}

FILES_${PN} += " \
    ${CONF_DIR}/ \
    ${optdir}/helium-gateway/helium-gateway \
"

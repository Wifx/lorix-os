HOMEPAGE = "https://www.helium.com/"
DESCRIPTION = "Helium Gateway"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=1c3a461cb3bfa8dedcbf13b9e8a6335a"

SRC_URI += "\
    file://000-remove-cargo-strip.patch \
    file://001-use-wifx-proto-no-rustfmt.patch \
    file://default.toml \
    file://settings.toml \
"

inherit cargo

RDEPENDS_${PN} += "curl"

DEPENDS += " \
    clang-native \
    cmake-native \
"

CONF_DIR = "${sysconfdir}/helium-gateway"
OPT_DIR = "${sysconfoptdir}/helium-gateway"
S = "${WORKDIR}/git"

do_install() {

    if [ "${CARGO_BUILD_TYPE}" = "--release" ]; then
        local cargo_bindir="${CARGO_RELEASE_DIR}"
    else
        local cargo_bindir="${CARGO_DEBUG_DIR}"
    fi

    # Config
    install -m 0664 default.toml     ${D}${CONF_DIR}/default.toml
    install -m 0664 settings.toml    ${D}${CONF_DIR}/settings.toml

    # Bin directory
    install -m 0775 -d ${D}${OPT_DIR}
    install -m 0777 ${cargo_bindir}/helium_gateway ${D}${OPT_DIR}/helium-gateway

}

FILES_${PN} += " \
    ${CONF_DIR}/ \
    ${OPT_DIR}/helium-gateway \
"

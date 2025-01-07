HOMEPAGE = "https://www.helium.com/"
DESCRIPTION = "Helium Gateway"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=1c3a461cb3bfa8dedcbf13b9e8a6335a"

SRC_URI += "\
    file://000-remove-cargo-strip.patch \
    file://settings.toml \
"

DEPENDS += "protobuf-native"

## meta-rust-bin
inherit cargo_bin

# Enable network for the compile task allowing cargo to download dependencies
do_compile[network] = "1"

CONF_DIR = "${sysconfoptdir}/helium-gateway"
OPT_DIR = "${optdir}/helium-gateway"
S = "${WORKDIR}/git"

do_install() {
    # Config
    install -m 0755 -d ${D}${CONF_DIR}
    install_config settings.toml

    # Bin directory
    install -m 0755 -d ${D}${OPT_DIR}
    install -m 0755 ${CARGO_BINDIR}/helium_gateway ${D}${OPT_DIR}/helium-gateway
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
    ${CONF_DIR}/ \
    ${OPT_DIR}/ \
"

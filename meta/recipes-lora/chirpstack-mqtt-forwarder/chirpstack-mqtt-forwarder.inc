HOMEPAGE = "https://www.chirpstack.io/"
DESCRIPTION = "ChirpStack MQTT Forwarder"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=bc4546f147d6f9892ca1b7d23bf41196"

SRC_URI += "\
    file://10-general.toml \
    file://20-lns.toml \
    file://30-backend.toml \
    file://40-metadata.toml \
    file://50-commands.toml \
"

UPX_COMPRESS_FILES:${PN} = "/opt/chirpstack-mqtt-forwarder/chirpstack-mqtt-forwarder"
inherit upx

## meta-rust-bin
inherit cargo_bin

# Enable network for the compile task allowing cargo to download dependencies
do_compile[network] = "1"

DEPENDS = " \
    openssl \
    protobuf-native \
    protobuf \
    protobuf-c \
    clang-native \
    cmake-native \
"

INSANE_SKIP:${PN} += "already-stripped"

export BINDGEN_EXTRA_CLANG_ARGS="-I${STAGING_INCDIR}"

CONF_DIR = "${sysconfoptdir}/chirpstack-mqtt-forwarder"
S = "${WORKDIR}/git"

do_install() {

    if [ "${CARGO_BUILD_TYPE}" = "--release" ]; then
        local cargo_bindir="${CARGO_RELEASE_DIR}"
    else
        local cargo_bindir="${CARGO_DEBUG_DIR}"
    fi

    # Configuration
    install -m 0755 -d ${D}${CONF_DIR}
    install_config 10-general.toml
    install_config 20-lns.toml
    install_config 30-backend.toml
    install_config 40-metadata.toml
    install_config 50-commands.toml 
    
    # Bin directory
    install -m 0755 -d ${D}${optdir}/chirpstack-mqtt-forwarder
    install -m 0755 ${cargo_bindir}/chirpstack-mqtt-forwarder ${D}${optdir}/chirpstack-mqtt-forwarder/chirpstack-mqtt-forwarder
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
    ${optdir}/chirpstack-mqtt-forwarder/chirpstack-mqtt-forwarder \
"

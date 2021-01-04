HOMEPAGE = "https://www.chirpstack.io/"
DESCRIPTION = "ChirpStack Concentratord"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=99e425257f8a67b7efd81dc0009ed8ff"

SRC_URI += "\
    file://channels/* \
    file://concentratord.toml \
    file://gateway.toml \
"

# TODO: add support for splitted config in the concentratord
#SRC_URI += "\
#    file://gateway-id.toml \
#    file://gateway-antenna.toml \
#    file://models/* \
#"

DEPENDS += " \
    clang-native \
    cmake-native \
"

DEPENDS_append_sx1301 = " libloragw-sx1301"
DEPENDS_append_sx1302 = " libloragw-sx1302"

inherit cargo

ASSUME_PROVIDED_remove = "cmake-native"

CONF_DIR = "${sysconfoptdir}/chirpstack-concentratord"
S = "${WORKDIR}/git"

export BINDGEN_EXTRA_CLANG_ARGS="-I${STAGING_INCDIR}"
 
CARGO_BUILD_FLAGS_append_sx1301 = " -p libconcentratord -p chirpstack-concentratord-sx1301 -p libloragw-sx1301"
CARGO_BUILD_FLAGS_append_sx1302 = " -p libconcentratord -p chirpstack-concentratord-sx1302 -p libloragw-sx1302"

do_install() {

    if [ "${CARGO_BUILD_TYPE}" = "--release" ]; then
        local cargo_bindir="${CARGO_RELEASE_DIR}"
    else
        local cargo_bindir="${CARGO_DEBUG_DIR}"
    fi

    install_configs

    install_channels
    
    # Bin directory
    install -m 0755 -d ${D}${optdir}/chirpstack-concentratord
}

install_configs() {
    install -m 0755 -d ${D}${CONF_DIR}
    install_config concentratord.toml                   00-concentratord.toml
    install_config gateway.toml                         10-gateway.toml
    #install_config gateway-id.toml                      11-gateway-id.toml
    #install_config models/wifx_lorix_one_863_870.toml   12-gateway-model.toml
    #install_config gateway-antenna.toml                 13-gateway-antenna.toml
}

install_config() {
    if [ -z "$1" ] || [ -z "$2"]; then
        bbfatal "Usage install_config <source> [dest]"
    fi

    install -m 0644 ${WORKDIR}/$1 ${D}${CONF_DIR}/$2
}

install_channels() {
    install -m 0755 -d ${D}${CONF_DIR}/channels
    
    install -m 0755 -d ${D}${CONF_DIR}/channels/EU868
    install -m 0644 ${WORKDIR}/channels/EU868/EU_863_870.toml ${D}${CONF_DIR}/channels/EU868/EU_863_870.toml
}

do_install_append_sx1301() {
    install -m 0755 ${cargo_bindir}/chirpstack-concentratord-sx1301 ${D}${optdir}/chirpstack-concentratord/chirpstack-concentratord
}

do_install_append_sx1302() {
    install -m 0755 ${cargo_bindir}/chirpstack-concentratord-sx1302 ${D}${optdir}/chirpstack-concentratord/chirpstack-concentratord
}

pkg_postinst_ontarget_${PN} () {
    if [ -z "$1" ]; then
        # execute only on first boot
        
        ### GATEWAY ID ###

        # TODO: update single separate file
        #GW_ID_FILE_PATH="${CONF_DIR}/11-gateway-id.toml"
        GW_ID_FILE_PATH="${CONF_DIR}/10-gateway.toml"

        # get gateway ID from its MAC address to generate an EUI-64 address
        GWID_MIDFIX="FFFE"
        MAC=$(ip link show eth0 | awk '/ether/ {print toupper($2)}')
        GWID_BEGIN=$(echo $MAC | awk -F\: '{print $1$2$3}')
        GWID_END=$(echo $MAC | awk -F\: '{print $4$5$6}')

        GWID="${GWID_BEGIN}${GWID_MIDFIX}${GWID_END}"
        
        sed -i 's/gateway_id=""/gateway_id="'${GWID}'"/g' $GW_ID_FILE_PATH

        echo "Gateway ID set to "$GWID" in file "$GW_ID_FILE_PATH

        ### FREQUENCY PLAN ###

        # TODO: set the active channel regarding hardware
        # Set active channel
        ln -snf "channels/EU868/EU_863_870.toml" "${CONF_DIR}/channels.toml"
        echo "Frequency plan set to 'EU_863_870'"
    fi
}

FILES_${PN} += " \
    ${CONF_DIR}/ \
    ${optdir}/chirpstack-concentratord/chirpstack-concentratord \
"
HOMEPAGE = "https://www.chirpstack.io/"
DESCRIPTION = "ChirpStack Concentratord"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=99e425257f8a67b7efd81dc0009ed8ff"

SRC_URI = "\
    git://github.com/brocaar/chirpstack-concentratord.git;protocol=git;tag=v${PV} \
    file://concentratord.toml \
    file://gateway.toml \
    file://gateway-id.toml \
    file://gateway-antenna.toml \
    file://models/* \
    file://channels/* \
"

DEPENDS = " \
    clang-native \
    libloragw-sx1301 \
    libloragw-sx1302 \
"

# Build should be done only for the correct concentrator, so that depends can be done only on the corresponding library
# DEPENDS += "${@bb.utils.contains('MACHINE_FEATURES', 'sx1301', 'libloragw-sx1301', '', d)}"
# DEPENDS += "${@bb.utils.contains('MACHINE_FEATURES', 'sx1302', 'libloragw-sx1302', '', d)}"

inherit cargo

CONF_DIR = "${sysconfoptdir}/chirpstack-concentratord"
S = "${WORKDIR}/git"

export BINDGEN_EXTRA_CLANG_ARGS="-I${STAGING_INCDIR}"

do_install() {

    if [ "${CARGO_BUILD_TYPE}" = "--release" ]; then
        local cargo_bindir="${CARGO_RELEASE_DIR}"
    else
        local cargo_bindir="${CARGO_DEBUG_DIR}"
    fi

    # gateway-id is only for the SX1302
    # TODO: manage its installation
    #install -m 0755 ${cargo_bindir}/gateway-id ${D}${optdir}/chirpstack-concentratord

    install_configs

    install_channels

    install_binary
}

install_configs() {
    install -m 0755 -d ${D}${CONF_DIR}
    install_config concentratord.toml               00-concentratord.toml
    install_config gateway.toml                     10-gateway.toml
    install_config gateway-id.toml                  11-gateway-id.toml
    install_config models/wifx_lorix_one_eu868.toml 12-gateway-model.toml
    install_config gateway-antenna.toml             13-gateway-antenna.toml
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

    # Set active channel
    ln -snf channels/EU868/EU_863_870.toml ${D}${CONF_DIR}/channels.toml
}

install_binary() {

    install -m 0755 -d ${D}${optdir}/chirpstack-concentratord

    if [ "${@bb.utils.contains('MACHINE_FEATURES', 'sx1301', 'true', 'false', d)}" = "true" ]; then
        concentrator="sx1301"
    fi
    
    if [ "${@bb.utils.contains('MACHINE_FEATURES', 'sx1302', 'true', 'false', d)}" = "true" ]; then
        if [ -z $concentrator ]; then
            bbfatal "Cannot have both sx1301 and sx1302"
        fi
        concentrator="sx1302"
    fi

    case $concentrator in
        "sx1301")
            install -m 0755 ${cargo_bindir}/chirpstack-concentratord-sx1301 ${D}${optdir}/chirpstack-concentratord/chirpstack-concentratord
            break
            ;;

        "sx1302")
            install -m 0755 ${cargo_bindir}/chirpstack-concentratord-sx1302 ${D}${optdir}/chirpstack-concentratord/chirpstack-concentratord
            break
            ;;

        *)
            bbfatal "concentratord needs either sx1301 or sx1302"
            ;;
    esac
}

pkg_postinst_ontarget_${PN} () {
    if [ -z "$1" ]; then
        # execute only on first boot
        
        GW_ID_FILE_PATH="${CONF_DIR}/11-gateway-id.toml"

        # get gateway ID from its MAC address to generate an EUI-64 address
        GWID_MIDFIX="FFFE"
        MAC=$(ip link show eth0 | awk '/ether/ {print toupper($2)}')
        GWID_BEGIN=$(echo $MAC | awk -F\: '{print $1$2$3}')
        GWID_END=$(echo $MAC | awk -F\: '{print $4$5$6}')

        GWID="${GWID_BEGIN}${GWID_MIDFIX}${GWID_END}"
        
        sed -i 's/gateway_id=""/gateway_id="'${GWID}'"/g' $GW_ID_FILE_PATH

        echo "Gateway ID set to "$GWID" in file "$GW_ID_FILE_PATH
    fi
}

FILES_${PN} += " \
    ${CONF_DIR}/ \
    ${optdir}/chirpstack-concentratord/chirpstack-concentratord \
"

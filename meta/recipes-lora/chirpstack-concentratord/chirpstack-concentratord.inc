HOMEPAGE = "https://www.chirpstack.io/"
DESCRIPTION = "ChirpStack Concentratord"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=99e425257f8a67b7efd81dc0009ed8ff"

PACKAGE_ARCH = "${MACHINE_ARCH}"

SRC_URI += "\
    file://concentratord.toml \
    file://gateways/gateway-l1.toml \
    file://gateways/gateway-lorix-one.toml \
    file://gateways/location.toml \
    file://channels/AS920/* \
    file://channels/AS923/* \
    file://channels/AU915/* \
    file://channels/EU868/* \
    file://channels/IN865/* \
    file://channels/RU864/* \
    file://channels/US915/* \
"

DEPENDS += " \
    clang-native \
    cmake-native \
"

RDEPENDS_${PN} += "machine-info"

DEPENDS_append_sx1301 = " libloragw-sx1301"
DEPENDS_append_sx1302 = " libloragw-sx1302"

inherit cargo

UPX_COMPRESS_FILES_${PN} = "/opt/chirpstack-concentratord/chirpstack-concentratord"
inherit upx

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
    install_config concentratord.toml 00-concentratord.toml
    install_config gateways/location.toml 11-location.toml
}

do_install_append_lorix-one() {
    install_config gateways/gateway-lorix-one.toml 10-gateway.toml
}

do_install_append_l1() {
    install_config gateways/gateway-l1.toml 10-gateway.toml
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

install_channels() {
    install -m 0755 -d ${D}${CONF_DIR}/channels
    
    install -m 0755 -d ${D}${CONF_DIR}/channels/AS920
    install_channel AS920/AS_920_923.toml
    set_default "AS920" "AS_920_923"

    install -m 0755 -d ${D}${CONF_DIR}/channels/AS923
    install_channel AS923/AS_923_925.toml
    install_channel AS923/AS_923_925_TTN_AU.toml
    set_default "AS923" "AS_923_925"
    
    install -m 0755 -d ${D}${CONF_DIR}/channels/AU915
    install_channel AU915/AU_915_928_FSB_1.toml
    install_channel AU915/AU_915_928_FSB_2.toml
    install_channel AU915/AU_915_928_FSB_3.toml
    install_channel AU915/AU_915_928_FSB_4.toml
    install_channel AU915/AU_915_928_FSB_5.toml
    install_channel AU915/AU_915_928_FSB_6.toml
    install_channel AU915/AU_915_928_FSB_7.toml
    install_channel AU915/AU_915_928_FSB_8.toml
    set_default "AU915" "AU_915_928_FSB_2"
    
    install -m 0755 -d ${D}${CONF_DIR}/channels/EU868
    install_channel EU868/EU_863_870.toml
    set_default "EU868" "EU_863_870"
    
    install -m 0755 -d ${D}${CONF_DIR}/channels/IN865
    install_channel IN865/IN_865_867.toml
    set_default "IN865" "IN_865_867"
    
    install -m 0755 -d ${D}${CONF_DIR}/channels/RU864
    install_channel RU864/RU_864_870_TTN.toml
    set_default "RU864" "RU_864_870_TTN"
    
    install -m 0755 -d ${D}${CONF_DIR}/channels/US915
    install_channel US915/US_902_928_FSB_1.toml
    install_channel US915/US_902_928_FSB_2.toml
    install_channel US915/US_902_928_FSB_3.toml
    install_channel US915/US_902_928_FSB_4.toml
    install_channel US915/US_902_928_FSB_5.toml
    install_channel US915/US_902_928_FSB_6.toml
    install_channel US915/US_902_928_FSB_7.toml
    install_channel US915/US_902_928_FSB_8.toml
    set_default "US915" "US_902_928_FSB_2"
}

install_channel() {
    if [ -z "$1" ]; then
        bbfatal "Usage install_channel <source> [dest]"
    fi

    if [ -z "$2"]; then
        DEST=$1
    else
        DEST=$2
    fi

    install -m 0644 ${WORKDIR}/channels/$1 ${D}${CONF_DIR}/channels/${DEST}
}

set_default() {
    REGION=$1
    ID=$2

    TARGET_PATH="${D}${CONF_DIR}/channels/$REGION/$ID.toml"

    if [ ! -f "$TARGET_PATH" ]; then
        bberror "Default Frequency plan '$ID' defined for region '$REGION' does not exist: '$TARGET_PATH'"
        exit 1
    fi;

    ln -snf "$ID.toml" "${D}${CONF_DIR}/channels/$REGION/default"
}


do_install_append_sx1301() {
    install -m 0755 ${cargo_bindir}/chirpstack-concentratord-sx1301 ${D}${optdir}/chirpstack-concentratord/chirpstack-concentratord
}

do_install_append_sx1302() {
    install -m 0755 ${cargo_bindir}/chirpstack-concentratord-sx1302 ${D}${optdir}/chirpstack-concentratord/chirpstack-concentratord
}

pkg_postinst_ontarget_${PN} () {
    ### GATEWAY ID ### # TODO: only for SX1301

    GW_ID_FILE_PATH="${CONF_DIR}/10-gateway.toml"

    # retrieve gateway ID from machine-info
    GWID=$(machine-info -e lora -n -f "LORA_GATEWAY_ID")
    
    sed -i 's/gateway_id=""/gateway_id="'${GWID}'"/g' $GW_ID_FILE_PATH

    echo "Gateway ID set to "$GWID" in file "$GW_ID_FILE_PATH


    ### FREQUENCY PLAN ###

    # Set default channel
    PRODUCT_FREQUENCY=$(machine-info -n -f "PRODUCT_FREQUENCY")
    CHANNELS_CONFDIR=/etc/opt/chirpstack-concentratord/channels

    if [ ! -f "$CHANNELS_CONFDIR/channels.toml" ]; then

        cd "$CHANNELS_CONFDIR"
        echo "Looking for concentratord channels for '$PRODUCT_FREQUENCY' in '$CHANNELS_CONFDIR'"

        # If the region provides a default channel plan, set it
        if [ -f "$PRODUCT_FREQUENCY/default" ]; then
            echo "Using default channel"
            CHANNEL_FILE_NAME=$(readlink "$PRODUCT_FREQUENCY/default")
            CHANNEL_FILE_PATH="$PRODUCT_FREQUENCY/$CHANNEL_FILE_NAME"
        else
            # Otherwise take the first in the list
            echo "Using first available channel in '$PRODUCT_FREQUENCY'"
            FILES="$PRODUCT_FREQUENCY/*.toml"
            for FILE in $FILES; do
                if [[ -f "$FILE" ]]; then
                    CHANNEL_FILE_PATH=$FILE
                    break
                fi
            done
        fi

        if [ ! -z "$CHANNEL_FILE_PATH" ]; then
            ln -snf "$CHANNEL_FILE_PATH" "channels_conf.toml"
            echo "concentratord channel has been set to '$CHANNEL_FILE_PATH'"
        else
            echo "Could not find any channel"
        fi

    else
        echo "concentratord channel already defined"
    fi
}

FILES_${PN} += " \
    ${CONF_DIR}/ \
    ${optdir}/chirpstack-concentratord/chirpstack-concentratord \
"

PACKAGE_ARCH = "${MACHINE_ARCH}"

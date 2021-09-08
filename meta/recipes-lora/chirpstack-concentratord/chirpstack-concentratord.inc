HOMEPAGE = "https://www.chirpstack.io/"
DESCRIPTION = "ChirpStack Concentratord"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=99e425257f8a67b7efd81dc0009ed8ff"

SRC_URI += "\
    file://0001-Add-Wifx-L1-863-870-config.patch \
    file://concentratord.toml \
    file://gateways/* \
    file://channels/* \
    file://channels/AS920/* \
    file://channels/AS923/* \
    file://channels/AU915/* \
    file://channels/EU868/* \
    file://channels/IN865/* \
    file://channels/RU864/* \
    file://channels/US915/* \
    file://0001-Add-Wifx-L1-863-870-config.patch \
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
RDEPENDS_${PN} += "machine-detect"

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
    #install_config gateway.toml                         10-gateway.toml
    #install_config gateway-id.toml                      11-gateway-id.toml
    #install_config models/wifx_lorix_one_863_870.toml   12-gateway-model.toml
    #install_config gateway-antenna.toml                 13-gateway-antenna.toml
}

do_install_append_lorix-one() {
    install -m 0644 ${WORKDIR}/gateways/gateway-lorix-one.toml ${D}${CONF_DIR}/10-gateway.toml
}

do_install_append_l1() {
    install -m 0644 ${WORKDIR}/gateways/gateway-l1.toml ${D}${CONF_DIR}/10-gateway.toml
}

install_config() {
    if [ -z "$1" ] || [ -z "$2"]; then
        bbfatal "Usage install_config <source> [dest]"
    fi

    install -m 0644 ${WORKDIR}/$1 ${D}${CONF_DIR}/$2
}

install_channels() {
    install -m 0755 -d ${D}${CONF_DIR}/channels
    
    install -m 0755 -d ${D}${CONF_DIR}/channels/AS920
    install -m 0644 ${WORKDIR}/channels/AS920/AS_920_923.toml ${D}${CONF_DIR}/channels/AS920/AS_920_923.toml
    set_default "AS920" "AS_920_923"

    install -m 0755 -d ${D}${CONF_DIR}/channels/AS923
    install -m 0644 ${WORKDIR}/channels/AS923/AS_923_925.toml ${D}${CONF_DIR}/channels/AS923/AS_923_925.toml
    install -m 0644 ${WORKDIR}/channels/AS923/AS_923_925_TTN_AU.toml ${D}${CONF_DIR}/channels/AS923/AS_923_925_TTN_AU.toml
    set_default "AS923" "AS_923_925"
    
    install -m 0755 -d ${D}${CONF_DIR}/channels/AU915
    install -m 0644 ${WORKDIR}/channels/AU915/AU_915_928_FSB_1.toml ${D}${CONF_DIR}/channels/AU915/AU_915_928_FSB_1.toml
    install -m 0644 ${WORKDIR}/channels/AU915/AU_915_928_FSB_2.toml ${D}${CONF_DIR}/channels/AU915/AU_915_928_FSB_2.toml
    install -m 0644 ${WORKDIR}/channels/AU915/AU_915_928_FSB_3.toml ${D}${CONF_DIR}/channels/AU915/AU_915_928_FSB_3.toml
    install -m 0644 ${WORKDIR}/channels/AU915/AU_915_928_FSB_4.toml ${D}${CONF_DIR}/channels/AU915/AU_915_928_FSB_4.toml
    install -m 0644 ${WORKDIR}/channels/AU915/AU_915_928_FSB_5.toml ${D}${CONF_DIR}/channels/AU915/AU_915_928_FSB_5.toml
    install -m 0644 ${WORKDIR}/channels/AU915/AU_915_928_FSB_6.toml ${D}${CONF_DIR}/channels/AU915/AU_915_928_FSB_6.toml
    install -m 0644 ${WORKDIR}/channels/AU915/AU_915_928_FSB_7.toml ${D}${CONF_DIR}/channels/AU915/AU_915_928_FSB_7.toml
    install -m 0644 ${WORKDIR}/channels/AU915/AU_915_928_FSB_8.toml ${D}${CONF_DIR}/channels/AU915/AU_915_928_FSB_8.toml
    set_default "AU915" "AU_915_928_FSB_2"
    
    install -m 0755 -d ${D}${CONF_DIR}/channels/EU868
    install -m 0644 ${WORKDIR}/channels/EU868/EU_863_870.toml ${D}${CONF_DIR}/channels/EU868/EU_863_870.toml
    set_default "EU868" "EU_863_870"
    
    install -m 0755 -d ${D}${CONF_DIR}/channels/IN865
    install -m 0644 ${WORKDIR}/channels/IN865/IN_865_867.toml ${D}${CONF_DIR}/channels/IN865/IN_865_867.toml
    set_default "IN865" "IN_865_867"
    
    install -m 0755 -d ${D}${CONF_DIR}/channels/RU864
    install -m 0644 ${WORKDIR}/channels/RU864/RU_864_870_TTN.toml ${D}${CONF_DIR}/channels/RU864/RU_864_870_TTN.toml
    set_default "RU864" "RU_864_870_TTN"
    
    install -m 0755 -d ${D}${CONF_DIR}/channels/US915
    install -m 0644 ${WORKDIR}/channels/US915/US_902_928_FSB_1.toml ${D}${CONF_DIR}/channels/US915/US_902_928_FSB_1.toml
    install -m 0644 ${WORKDIR}/channels/US915/US_902_928_FSB_2.toml ${D}${CONF_DIR}/channels/US915/US_902_928_FSB_2.toml
    install -m 0644 ${WORKDIR}/channels/US915/US_902_928_FSB_3.toml ${D}${CONF_DIR}/channels/US915/US_902_928_FSB_3.toml
    install -m 0644 ${WORKDIR}/channels/US915/US_902_928_FSB_4.toml ${D}${CONF_DIR}/channels/US915/US_902_928_FSB_4.toml
    install -m 0644 ${WORKDIR}/channels/US915/US_902_928_FSB_5.toml ${D}${CONF_DIR}/channels/US915/US_902_928_FSB_5.toml
    install -m 0644 ${WORKDIR}/channels/US915/US_902_928_FSB_6.toml ${D}${CONF_DIR}/channels/US915/US_902_928_FSB_6.toml
    install -m 0644 ${WORKDIR}/channels/US915/US_902_928_FSB_7.toml ${D}${CONF_DIR}/channels/US915/US_902_928_FSB_7.toml
    install -m 0644 ${WORKDIR}/channels/US915/US_902_928_FSB_8.toml ${D}${CONF_DIR}/channels/US915/US_902_928_FSB_8.toml
    set_default "US915" "US_902_928_FSB_2"
}

set_default() {
    REGION=$1
    ID=$2

    TARGET_PATH="${D}${CONF_DIR}/channels/$REGION/$ID.toml"

    if [ ! -f "$TARGET_PATH" ]; then
        bberror "Default Frequency plan '$ID' defined for region '$REGION' does not exist: '$TARGET_PATH'"
        exit 1
    fi;

    ln -snf "$ID.json" "${D}${CONF_DIR}/channels/$REGION/default"
}


do_install_append_sx1301() {
    install -m 0755 ${cargo_bindir}/chirpstack-concentratord-sx1301 ${D}${optdir}/chirpstack-concentratord/chirpstack-concentratord
}

do_install_append_sx1302() {
    install -m 0755 ${cargo_bindir}/chirpstack-concentratord-sx1302 ${D}${optdir}/chirpstack-concentratord/chirpstack-concentratord
}

# TODO: only for SX1301
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

        # Set default channel
        source /etc/os/.machine-detect && machine_detect
        CHANNELS_CONFDIR=/etc/opt/chirpstack-concentratord/channels

        if [ ! -f "$CHANNELS_CONFDIR/channels.toml" ]; then

            cd "$CHANNELS_CONFDIR"
            echo "Looking for concentratord channels for '$MACHINE_TYPE' in '$CHANNELS_CONFDIR'"

            # If the region provides a default channel plan, set it
            if [ -f "$MACHINE_TYPE/default" ]; then
                echo "Using default channel"
                CHANNEL_FILE_NAME=$(readlink "$MACHINE_TYPE/default")
                CHANNEL_FILE_PATH="$MACHINE_TYPE/$CHANNEL_FILE_NAME"
            else
                # Otherwise take the first in the list
                echo "Using first available channel in '$MACHINE_TYPE'"
                FILES="$MACHINE_TYPE/*.toml"
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
    fi
}

FILES_${PN} += " \
    ${CONF_DIR}/ \
    ${optdir}/chirpstack-concentratord/chirpstack-concentratord \
"

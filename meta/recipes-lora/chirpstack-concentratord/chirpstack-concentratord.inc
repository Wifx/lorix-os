# Copyright (c) 2025, Wifx SA <info@iot.wifx.net>
# All rights reserved.

HOMEPAGE = "https://www.chirpstack.io/"
DESCRIPTION = "ChirpStack Concentratord"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=bc4546f147d6f9892ca1b7d23bf41196"

FILESEXTRAPATHS:prepend := "${THISDIR}/v4:"

SRC_URI += "\
    file://concentratord.toml \
    file://gateways/gateway-l1.toml \
    file://gateways/gateway-lorix-one.toml \
    file://gateways/location.toml \
    file://channels/AS920/AS_920_923.toml \
    file://channels/AS923/AS_923_925_TTN_AU.toml \
    file://channels/AS923/AS_923_925.toml \
    file://channels/AU915/AU_915_928_FSB_1.toml \
    file://channels/AU915/AU_915_928_FSB_2.toml \
    file://channels/AU915/AU_915_928_FSB_3.toml \
    file://channels/AU915/AU_915_928_FSB_4.toml \
    file://channels/AU915/AU_915_928_FSB_5.toml \
    file://channels/AU915/AU_915_928_FSB_6.toml \
    file://channels/AU915/AU_915_928_FSB_7.toml \
    file://channels/AU915/AU_915_928_FSB_8.toml \
    file://channels/EU868/EU_863_870.toml \
    file://channels/IN865/IN_865_867.toml \
    file://channels/RU864/RU_864_870_TTN.toml \
    file://channels/US915/US_902_928_FSB_1.toml \
    file://channels/US915/US_902_928_FSB_2.toml \
    file://channels/US915/US_902_928_FSB_3.toml \
    file://channels/US915/US_902_928_FSB_4.toml \
    file://channels/US915/US_902_928_FSB_5.toml \
    file://channels/US915/US_902_928_FSB_6.toml \
    file://channels/US915/US_902_928_FSB_7.toml \
    file://channels/US915/US_902_928_FSB_8.toml \
"

DEPENDS = " \
    protobuf-native \
    clang-native \
"
ASSUME_PROVIDED:remove = "cmake-native"

DEPENDS:append:sx1301 = " libloragw-sx1301"
DEPENDS:append:sx1302 = " libloragw-sx1302"

RDEPENDS:${PN} += "machine-info"

inherit upx
UPX_COMPRESS_FILES:${PN} = "${optdir}/chirpstack-concentratord/chirpstack-concentratord"

CONF_DIR = "${sysconfoptdir}/chirpstack-concentratord"
S = "${WORKDIR}/git"

## meta-rust
inherit cargo cargo-update-recipe-crates

# Fix panic static and configure options (SQLite based)
RUST_PANIC_STRATEGY = "abort"

# Remove TMPDIR reference in C based crates
DEBUG_PREFIX_MAP:append = " \
    -fmacro-prefix-map=${WORKDIR}=/usr/src/debug/${PN}/${EXTENDPE}${PV}-${PR} \
    -fdebug-prefix-map=${WORKDIR}=/usr/src/debug/${PN}/${EXTENDPE}${PV}-${PR} \
"

export BINDGEN_EXTRA_CLANG_ARGS="--sysroot=${STAGING_DIR_TARGET}"
export BINDGEN_EXTRA_CLANG_ARGS="-I${STAGING_INCDIR}"

CARGO_BUILD_FLAGS:append = " -p libconcentratord"
CARGO_BUILD_FLAGS:append:sx1301 = " -p chirpstack-concentratord-sx1301 -p libloragw-sx1301"
CARGO_BUILD_FLAGS:append:sx1302 = " -p chirpstack-concentratord-sx1302 -p libloragw-sx1302" 

do_install() {
    install_configs

    install_channels

    # Bin directory
    install -m 0755 -d ${D}${optdir}/chirpstack-concentratord
}

do_install:append:lorix-one() {
    # Machine specific config
    install_config gateways/gateway-lorix-one.toml 10-gateway.toml
}

do_install:append:l1() {
    # Machine specific config
    install_config gateways/gateway-l1.toml 10-gateway.toml
}

do_install:append:sx1301() {
    install -m 0755 ${B}/target/${CARGO_TARGET_SUBDIR}/chirpstack-concentratord-sx1301 ${D}${optdir}/chirpstack-concentratord/chirpstack-concentratord
}

do_install:append:sx1302() {
    install -m 0755 ${B}/target/${CARGO_TARGET_SUBDIR}/chirpstack-concentratord-sx1302 ${D}${optdir}/chirpstack-concentratord/chirpstack-concentratord
}

install_configs() {
    install -m 0755 -d ${D}${CONF_DIR}
    install_config concentratord.toml 00-concentratord.toml
    install_config gateways/location.toml 11-location.toml
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

pkg_postinst_ontarget:${PN} () {
    GW_CONFIG_FILE_PATH="${CONF_DIR}/10-gateway.toml"
}

pkg_postinst_ontarget:${PN}:append:lorix_one () {

    ### GATEWAY ID ### 

    if [ -f "$GW_CONFIG_FILE_PATH" ]; then
        # retrieve gateway ID from machine-info
        GWID=$(machine-info read "LORA_GATEWAY_ID")
        
        sed -i 's/gateway_id=""/gateway_id="'${GWID}'"/g' $GW_CONFIG_FILE_PATH

        echo "Gateway ID set to "$GWID" in file "$GW_CONFIG_FILE_PATH
    else
        echo "Gateway config file does not exist ("$GW_CONFIG_FILE_PATH")"
    fi

    ### MODEL FLAGS ###

    if [ -f "$GW_CONFIG_FILE_PATH" ]; then
        # retrieve LoRa Region from machine-info
        LORA_REGION=$(machine-info read "PRODUCT_VARIANT_ATTR_LORA_REGION")

        sed -i 's/lora_region-XXX/lora_region-'${LORA_REGION}'/g' $GW_CONFIG_FILE_PATH

        echo "lora_region set to "$LORA_REGION" in file "$GW_CONFIG_FILE_PATH
    else
        echo "Gateway config file does not exist ("$GW_CONFIG_FILE_PATH")"
    fi
}

pkg_postinst_ontarget:${PN}:append:l1 () {

    ### MODEL FLAGS ###

    if [ -f "$GW_CONFIG_FILE_PATH" ]; then
        # retrieve LoRa Region from machine-info
        LORA_REGION=$(machine-info read "PRODUCT_VARIANT_ATTR_LORA_REGION")
        
        # retrieve LoRa frontend revision from machine-info
        LORA_FRONTEND_REV=$(machine-info read "LORA_IFACE_0_FRONTEND_REV")
        
        sed -i 's/lora_region-XXX/lora_region-'${LORA_REGION}'/g' $GW_CONFIG_FILE_PATH
        echo "lora_region set to "$LORA_REGION" in file "$GW_CONFIG_FILE_PATH

        sed -i 's/lora_frontend_rev-X/lora_frontend_rev-'${LORA_FRONTEND_REV}'/g' $GW_CONFIG_FILE_PATH
        echo "lora_frontend_rev set to "$LORA_FRONTEND_REV" in file "$GW_CONFIG_FILE_PATH

    else
        echo "Gateway config file does not exist ("$GW_CONFIG_FILE_PATH")"
    fi
}

FILES:${PN} += " \
    ${CONF_DIR}/ \
    ${optdir}/chirpstack-concentratord/chirpstack-concentratord \
"

PACKAGE_ARCH = "${MACHINE_ARCH}"

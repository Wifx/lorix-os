SUMMARY = "LoRa SX1301 based gateway UDP packet forwarder"
DESCRIPTION = "LoRa SX1301 based gateway UDP packet forwarder"
AUTHOR = "Wifx SA <support@iot.wifx.net>"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=8aebde4f3f92d0e71e58871d97d7420f"

CVE_PRODUCT = "wifx:udp-packet-forwarder"

PACKAGE_ARCH = "${MACHINE_ARCH}"

RDEPENDS:${PN} += " \
    libcrypto \
    machine-info \
"
RPROVIDES:${PN} += "udp-packet-forwarder"

INSANE_SKIP:${PN} += "file-rdeps"

SRC_URI += " \
    file://udp-packet-forwarder-generic.yml \
    file://channels/AS920/AS_920_923.json \
    file://channels/AS923/AS_923_925.json \
    file://channels/AS923/AS_923_925_TTN_AU.json \
    file://channels/AU915/AU_915_928_FSB_1.json \
    file://channels/AU915/AU_915_928_FSB_2.json \
    file://channels/AU915/AU_915_928_FSB_3.json \
    file://channels/AU915/AU_915_928_FSB_4.json \
    file://channels/AU915/AU_915_928_FSB_5.json \
    file://channels/AU915/AU_915_928_FSB_6.json \
    file://channels/AU915/AU_915_928_FSB_7.json \
    file://channels/AU915/AU_915_928_FSB_8.json \
    file://channels/EU868/EU_863_870.json \
    file://channels/IN865/IN_865_867.json \
    file://channels/RU864/RU_864_870_TTN.json \
    file://channels/US915/US_902_928_FSB_1.json \
    file://channels/US915/US_902_928_FSB_2.json \
    file://channels/US915/US_902_928_FSB_3.json \
    file://channels/US915/US_902_928_FSB_4.json \
    file://channels/US915/US_902_928_FSB_5.json \
    file://channels/US915/US_902_928_FSB_6.json \
    file://channels/US915/US_902_928_FSB_7.json \
    file://channels/US915/US_902_928_FSB_8.json \
    file://gateway/generic/gateway_global_conf.json \
    file://gateway/generic/gateway_local_conf.json \
    file://gateway/ttn/gateway_global_conf.json \
    file://gateway/ttn/gateway_local_conf.json \
    file://LICENSE \
"

SRC_URI:append:lorix-one = " \
    file://resources-lorix-one/hardware/8XX/hardware_conf_2dBi.json \
    file://resources-lorix-one/hardware/8XX/hardware_conf_2dBi.json.sha256 \
    file://resources-lorix-one/hardware/8XX/hardware_conf_3dBi.json \
    file://resources-lorix-one/hardware/8XX/hardware_conf_3dBi.json.sha256 \
    file://resources-lorix-one/hardware/8XX/hardware_conf_4dBi.json \
    file://resources-lorix-one/hardware/8XX/hardware_conf_4dBi.json.sha256 \
    file://resources-lorix-one/hardware/8XX/hardware_conf_5dBi.json \
    file://resources-lorix-one/hardware/8XX/hardware_conf_5dBi.json.sha256 \
    file://resources-lorix-one/hardware/9XX/hardware_conf_2dBi.json \
    file://resources-lorix-one/hardware/9XX/hardware_conf_2dBi.json.sha256 \
    file://resources-lorix-one/hardware/9XX/hardware_conf_3dBi.json \
    file://resources-lorix-one/hardware/9XX/hardware_conf_3dBi.json.sha256 \
    file://resources-lorix-one/hardware/9XX/hardware_conf_4dBi.json \
    file://resources-lorix-one/hardware/9XX/hardware_conf_4dBi.json.sha256 \
    file://resources-lorix-one/hardware/9XX/hardware_conf_5dBi.json \
    file://resources-lorix-one/hardware/9XX/hardware_conf_5dBi.json.sha256 \
"

S = "${WORKDIR}/git"
B = "${S}"

CONF = "${D}${sysconfoptdir}/udp-packet-forwarder"

inherit unpack-online-assets pmonitor

do_install() {
    # binary
    install -m 0755 -d ${D}${optdir}/udp-packet-forwarder
    install -m 0755 ${S}/bin/udp-packet-forwarder ${D}${optdir}/udp-packet-forwarder/udp-packet-forwarder
    ln -snf ${optdir}/udp-packet-forwarder/udp-packet-forwarder ${D}${optdir}/udp-packet-forwarder/udp-pkt-fwd
    ln -snf ${optdir}/udp-packet-forwarder/udp-packet-forwarder ${D}${optdir}/udp-packet-forwarder/upf

    # Configuration files
    install -m 0755 -d ${CONF}
    install -m 0755 -d ${CONF}/hardware
    install -m 0755 -d ${CONF}/channels
    install -m 0755 -d ${CONF}/gateway

    install -m 0755 -d ${CONF}/gateway/generic
    install -m 0644 -D "${WORKDIR}/gateway/generic/gateway_global_conf.json" "${CONF}/gateway/generic/"
    install -m 0644 -D "${WORKDIR}/gateway/generic/gateway_local_conf.json" "${CONF}/gateway/generic/"

    install_channels

    # Pmonitor service configuration files
    pmonitor_service_install ${WORKDIR}/udp-packet-forwarder-generic.yml
}

do_install:append:lorix-one() {
    # configuration files
    install -m 0755 -d ${CONF}/hardware
    cd ${WORKDIR}/resources-lorix-one/hardware
    for file in $(find . -type f -name '*.json' -o -name '*.json.sha256'); do
        install -m 0644 -D "${WORKDIR}/resources-lorix-one/hardware/$file" "${CONF}/hardware/$file"
    done
}

install_channels() {
    # install channels conf files
    install -m 0755 -d ${CONF}/channels
    cd ${WORKDIR}/channels
    for file in $(find . -type f -name '*.json'); do
        install -m 0644 -D "${WORKDIR}/channels/$file" "${CONF}/channels/$file"
    done

    set_default "AS920" "AS_920_923"
    set_default "AS923" "AS_923_925"
    set_default "AU915" "AU_915_928_FSB_2"
    set_default "EU868" "EU_863_870"
    set_default "IN865" "IN_865_867"
    set_default "RU864" "RU_864_870_TTN"
    set_default "US915" "US_902_928_FSB_2"
}

set_default() {
    REGION=$1
    ID=$2

    TARGET_PATH="${D}${sysconfoptdir}/udp-packet-forwarder/channels/$REGION/$ID.json"

    if [ ! -f "$TARGET_PATH" ]; then
        bberror "Default Frequency plan '$ID' defined for region '$REGION' does not exist: '$TARGET_PATH'"
        exit 1
    fi;

    ln -snf "$ID.json" "${D}${sysconfoptdir}/udp-packet-forwarder/channels/$REGION/default"
}

pkg_postinst_ontarget:${PN} () {
    # Update gateway ID in general config files

    CONF_DIR="${sysconfoptdir}/udp-packet-forwarder/gateway"
    if [ ! -d "$CONF_DIR" ]; then
        echo "Configuration directory '$CONF_DIR' does not exist"
        exit 0
    fi

    # retrieve gateway ID from machine-info
    GWID=$(machine-info read "LORA_GATEWAY_ID")
    if [ $? -ne 0 ] || [ -z "$GWID" ]; then
        echo "Error: Failed to retrieve LORA_GATEWAY_ID from machine-info"
        exit 1
    fi

    # Find files and process them safely
    find "$CONF_DIR" -type f \( -name '*.json' -o -name '*.json.sample' \) | while read -r file; do
        # Check if gateway_ID is empty in the file
        if grep -q '^\s*"gateway_ID":\s*"",' "$file"; then
            # replace empty gateway ID by actual GWID
            if sed -i 's/\(^\s*"gateway_ID":\s*"\)"",/\1'${GWID}'",/' "$file"; then
                echo "Gateway_ID set to '$GWID' in file '$file'"
            else
                echo "Error: Failed to set Gateway_ID in file '$file'"
                exit 1
            fi
        fi
    done
}

FILES:${PN} += "${optdir}"
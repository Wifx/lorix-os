SUMMARY = "LoRa SX1301 based gateway UDP packet forwarder"
DESCRIPTION = "LoRa SX1301 based gateway UDP packet forwarder"
AUTHOR = "Wifx Sàrl <support@iot.wifx.net>"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=8aebde4f3f92d0e71e58871d97d7420f"

RDEPENDS_${PN} += "libcrypto"
RPROVIDES_${PN} += "virtual/udp-packet-forwarder"

SRC_URI += " \
    file://udp-packet-forwarder-generic.yml \
    file://channels \
    file://gateway \
    file://LICENSE \
"

SRC_URI_append_lorix-one = " \
    file://resources-lorix-one \
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

do_install_append_lorix-one() {
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
    set_default "US915" "US_902_928_FSB_1"
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

pkg_postinst_ontarget_${PN} () {
    if [ -z "$1" ]; then
        # execute only on first boot
        
        # Update gateway ID in general config files

        # get gateway ID from its MAC address to generate an EUI-64 address
        GWID_MIDFIX="FFFE"
        MAC=$(ip link show eth0 | awk '/ether/ {print toupper($2)}')
        GWID_BEGIN=$(echo $MAC | awk -F\: '{print $1$2$3}')
        GWID_END=$(echo $MAC | awk -F\: '{print $4$5$6}')
        GWID=${GWID_BEGIN}${GWID_MIDFIX}${GWID_END}

        cd ${sysconfoptdir}/udp-packet-forwarder/gateway
        for file in $(find . -type f -name '*.json' -o -name '*.json.sample'); do
            # replace last 8 digits of default gateway ID by actual GWID, in given JSON configuration file
            sed -i 's/\(^\s*"gateway_ID":\s*"\).\{16\}"\s*\(,\?\).*$/\1'${GWID}'"\2/' $file
            echo "Gateway_ID set to "$GWID" in file "$file
        done

        # Set default channel
        PRODUCT_TYPE=$(cat /sys/class/product/machine/product_type)
        CHANNELS_CONFDIR=/etc/opt/udp-packet-forwarder/channels

        if [ ! -f "$CHANNELS_CONFDIR/channels_conf.json" ]; then

            cd $CHANNELS_CONFDIR
            echo "Looking for UDP Packet Forwarder channels for '$PRODUCT_TYPE' in '$CHANNELS_CONFDIR'"

            # If the region provides a default channel plan, set it
            if [ -f "$PRODUCT_TYPE/default" ]; then
                CHANNEL_FILE_NAME=$(readlink "$PRODUCT_TYPE/default")
                CHANNEL_FILE_PATH="$PRODUCT_TYPE/$CHANNEL_FILE_NAME"

            else
                # Otherwise take the first in the list
                FILES="$PRODUCT_TYPE/*.json"
                for FILE in $FILES; do
                    if [[ -f "$FILE" ]]; then
                        CHANNEL_FILE_PATH=$FILE
                        break
                    fi
                done
            fi

            if [ ! -z "$CHANNEL_FILE_PATH"]; then
                ln -snf "$CHANNEL_FILE_PATH" "channels_conf.json"
                echo "UDP Packet Forwarder channel has been set to '$CHANNEL_FILE_PATH'"
            else
                echo "Could not find any channel"
            fi

        else
            echo "UDP Packet Forwarder channel already defined"
        fi
    fi
}

FILES_${PN} += "${optdir}"
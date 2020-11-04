SUMMARY = "LoRa SX1301 based gateway UDP packet forwarder"
DESCRIPTION = "LoRa SX1301 based gateway UDP packet forwarder"
AUTHOR = "Wifx Sàrl <support@iot.wifx.net>"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=8aebde4f3f92d0e71e58871d97d7420f"

RDEPENDS_${PN} += "libcrypto udp-packet-forwarder-arch-config"
RPROVIDES_${PN} += "virtual/lora-packet-forwarder"

SRC_URI = " \
    file://udp-packet-forwarder-generic.yml \
    file://resources \
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
    install -m 0644 -D "${WORKDIR}/resources/gateway/generic/gateway_global_conf.json" "${CONF}/gateway/generic/"
    install -m 0644 -D "${WORKDIR}/resources/gateway/generic/gateway_local_conf.json" "${CONF}/gateway/generic/"

    # Pmonitor service configuration files
    pmonitor_service_install ${WORKDIR}/udp-packet-forwarder-generic.yml
}

pkg_postinst_ontarget_${PN} () {
    if [ -z "$1" ]; then
        # execute only on first boot

        PRODUCT_TYPE=$(cat /sys/class/product/machine/product_type)
        CHANNELS_CONFDIR=/etc/opt/udp-packet-forwarder/channels

        if [ ! -f "$CHANNELS_CONFDIR/channels_conf.json" ]; then

            cd $CHANNELS_CONFDIR
            echo "Looking for UDP Packet Forwarder channels for '$PRODUCT_TYPE' in '$CHANNELS_CONFDIR'"

            FILES="$PRODUCT_TYPE/*.json"
            for FILE in $FILES; do
                if [[ -f "$FILE" ]]; then
                    ln -snf "$FILE" "channels_conf.json"
                    echo "UDP Packet Forwarder channel has been set to '$FILE'"
                    exit 0
                fi
            done

            echo "Could not find any channel"
        else
            echo "UDP Packet Forwarder channel already defined"
        fi
    fi
}

FILES_${PN} += "${optdir}"
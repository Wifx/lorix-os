SUMMARY = "Semtech LoRa SX1301 based gateway packet forwarder"
DESCRIPTION = "Semtech LoRa SX1301 based gateway packet forwarder"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=22af7693d7b76ef0fc76161c4be76c45"

S = "${WORKDIR}/git"
B = "${S}"
SRCTAG = "v${PV}"
SRC_URI = " \
    git://github.com/Lora-net/packet_forwarder.git;protocol=git;tag=${SRCTAG} \
    file://lora-packet-forwarder.yml \
    file://resources/global_conf_AS2_4dBi_outdoor.json \
    file://resources/global_conf_AU915_4dBi_outdoor.json \
    file://resources/global_conf_EU868_2dBi_indoor.json \
    file://resources/global_conf_EU868_4dBi_outdoor.json \
    file://resources/global_conf_US915_4dBi_outdoor.json \
    file://resources/local_conf.json \
"

RPROVIDES_${PN} += "virtual/lora-packet-forwarder"
DEPENDS += "libloragw"

TARGET_CC_ARCH += "${LDFLAGS}"

EXTRA_OEMAKE = " \
    'CC=${CC}' 'CFLAGS=${CFLAGS} \
    -I${S}/lora_pkt_fwd/inc \
    -I${STAGING_DIR_TARGET}${includedir}/libloragw' \
    'LDFLAGS=-lloragw -lrt -lpthread -lm' \
    'BUILDDIR=${S}' \
    'LGW_PATH=${STAGING_DIR_TARGET}${libdir}/libloragw' \
    'CFG_SPI=native' \
"

inherit pmonitor

do_compile() {
    cd ${S}/lora_pkt_fwd
    base_do_compile
}

do_install() {
    # binary
    install -m 0755 -d ${D}${optdir}/lpf
    install -m 0744 ${S}/lora_pkt_fwd/lora_pkt_fwd ${D}${optdir}/lpf/lora-pkt-fwd
    ln -sr ${D}${optdir}/lpf/lora-pkt-fwd ${D}${optdir}/lpf/lpf

    # configuration files
    install -m 0755 -d ${D}${sysconfoptdir}/lpf/configs
    cd ${WORKDIR}/resources
    for file in $(find . -type f -name '*.json' -o -name '*.json.sample'); do
        install -m 0644 -D "${WORKDIR}/resources/$file" "${D}${sysconfoptdir}/lpf/configs/$file"
    done

    # TODO : remove, it should be done dynamically in postinst
    ln -sr "${D}${sysconfoptdir}/lpf/configs/global_conf_EU868_2dBi_indoor.json" "${D}${sysconfoptdir}/lpf/global_conf.json"
    mv "${D}${sysconfoptdir}/lpf/configs/local_conf.json" "${D}${sysconfoptdir}/lpf/local_conf.json"

    # Pmonitor service configuration files
    pmonitor_service_install ${WORKDIR}/lora-packet-forwarder.yml
}

FILES_${PN} += "${optdir}/lpf"

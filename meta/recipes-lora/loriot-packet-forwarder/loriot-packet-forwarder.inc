SUMMARY = "LORIOT lora packet forwarder"
DESCRIPTION = "LORIOT LoRa SX1301 based gateway packet forwarder"
AUTHOR = "LORIOT"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=63722c69679e7db558ef8786ac6de1b1"

SRC_URI += " \
	file://LICENSE \
    file://loriot-packet-forwarder.yml \
"

S = "${WORKDIR}"

INSANE_SKIP_${PN} += "already-stripped"

inherit pmonitor

do_install () {
    # binary
    install -m 0755 -d ${D}${optdir}/loriot
    install -m 0755 ${WORKDIR}/${BIN_SRC_FILE_NAME} ${D}${optdir}/loriot/loriot-pkt-fwd
    ln -snf ${optdir}/loriot/loriot-pkt-fwd ${D}${optdir}/loriot/loriot-packet-forwarder

    # Pmonitor service configuration files
    pmonitor_service_install ${WORKDIR}/loriot-packet-forwarder.yml
}

FILES_${PN} += "${optdir}/loriot"
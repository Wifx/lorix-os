SUMMARY = "Basic scripts which manages the SX130X LoRa concentrator"
DESCRIPTION = "This package provides the script which manages the RESET pin of the SX1301 RF gateway chip"
AUTHOR = "Wifx Sàrl"
SECTION = "base"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=83564c4ad755d0edeaa1ba4b3918b365"

RDEPENDS_${PN} += "bash"

SRC_URI += " \
    file://LICENSE \
    file://lora-concentrator-reset.sh \
"

PR = "r0"
S = "${WORKDIR}"

INITSCRIPT_NAME="lora-concentrator"

inherit update-rc.d

do_install () {
	install -d ${D}${sbindir}
	install -m 0754 ${WORKDIR}/lora-concentrator-reset.sh ${D}${sbindir}/lora-concentrator-reset
	ln -snf lora-concentrator-reset ${D}${sbindir}/reset-lgw
}

FILES_${PN} =+ " \
    ${sbindir}/lora-concentrator-reset \
    ${sbindir}/reset-lgw \
"

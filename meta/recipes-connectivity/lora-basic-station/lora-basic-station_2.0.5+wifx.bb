SUMMARY = "The Basic Station is a LoRaWAN packet forwarder"
DESCRIPTION = "LoRa Basic Station"
HOMEPAGE = "https://doc.sm.tc/station/"
AUTHOR = "Semtech LoRa Basics"

LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=5ffc1514bf7cad7ad7892ca90a7295cd"

SRCTAG = "v${PV}"

#SRC_URI = "git://github.com/lorabasics/basicstation.git;protocol=git;tag=${SRCTAG}"
SRC_URI = "git://github.com/wifx/basicstation.git;protocol=git;tag=${SRCTAG}"

SRC_URI += " \
    file://lora-basic-station.yml \
"

# At the moment, the library are compiled directly from package sources
#DEPENDS += "libloragw mbedtls"

inherit pmonitor

RDEPENDS_${PN} += "lora-basic-station-arch-config lora-concentrator"
RPROVIDES_${PN} += "virtual/lora-packet-forwarder"

S = "${WORKDIR}/git"

do_configure() {
    path="${S}/deps/lgw"
    # copy existing lgw linux patch for the lorix
    cp -f ${path}/v5.0.1-linux.patch ${path}/v5.0.1-lorix.patch
}

TARGET_CC_ARCH += "${LDFLAGS}"

do_compile() {
    make platform=lorix variant=std \
        ARCH.lorix=${TARGET_SYS} \
        TOOLCHAIN=${STAGING_BINDIR_TOOLCHAIN} \
        CFG.${TARGET_SYS}=linux \
        CFG.lorix="linux lgw1 no_leds" \
        LIBS.lorix="-llgw -lmbedtls -lmbedx509 -lmbedcrypto -lpthread"
}

do_install() {
    # binary
    install -m 0755 -d ${D}${optdir}/lora-basic-station
    install -m 0744 ${S}/build-lorix-std/bin/station ${D}${optdir}/lora-basic-station/lora-basic-station
    
    # Pmonitor service configuration files
    pmonitor_service_install ${WORKDIR}/lora-basic-station.yml
}

FILES_${PN} += "${optdir}"
DESCRIPTION = "LoRa Basic Station"
HOMEPAGE = "https://doc.sm.tc/station/"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=8800e52406ffa1fc7eac718f37f653ee"

#SRCTAG = "v${PV}"
#SRC_URI = "git://github.com/Wifx/basicstation.git;protocol=git;tag=${SRCTAG}"
SRCREV = "250b4e58aa1cd3cd15a3031a6c5924fa564b71fa"
SRC_URI = "git://github.com/Wifx/basicstation.git;protocol=git"

SRC_URI += " \
    file://lora-basic-station.yml \
"

# At the moment, the library are compiled directly from package sources
#DEPENDS += "libloragw mbedtls"

inherit pmonitor

RDEPENDS_${PN} += "lora-basic-station-arch-config"
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
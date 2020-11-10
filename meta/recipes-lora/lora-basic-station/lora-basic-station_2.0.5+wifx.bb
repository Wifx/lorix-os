SUMMARY = "The Basic Station is a LoRaWAN packet forwarder"
DESCRIPTION = "LoRa Basic Station"
HOMEPAGE = "https://doc.sm.tc/station/"
AUTHOR = "Semtech LoRa Basics"

LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=5ffc1514bf7cad7ad7892ca90a7295cd"

SRCTAG = "v${PV}"

#SRC_URI = "git://github.com/lorabasics/basicstation.git;protocol=git;tag=${SRCTAG}"
SRC_URI = "git://github.com/Wifx/basicstation.git;protocol=git;tag=${SRCTAG}"

SRC_URI += " \
    file://lora-basic-station.yml \
"

SRC_URI_append_lorix-one += "file://setup-lorix.gmk"

# At the moment, the library are compiled directly from package sources
#DEPENDS += "libloragw mbedtls"

inherit pmonitor

RDEPENDS_${PN} += "lora-basic-station-arch-config lora-concentrator"

S = "${WORKDIR}/git"

do_configure() {
    cp -f ${WORKDIR}/setup-*.gmk ${S}
}

do_configure_append_lorix-one() {
    path="${S}/deps/lgw"
    # copy existing lgw linux patch for the lorix
    cp -f ${path}/v5.0.1-linux.patch ${path}/v5.0.1-lorix.patch
}

TARGET_CC_ARCH += "${LDFLAGS}"

do_compile_lorix-one() {
    make platform=lorix variant=std \
        ARCH.lorix=${TARGET_SYS} \
        TOOLCHAIN=${STAGING_BINDIR_TOOLCHAIN} \
        CFG.${TARGET_SYS}=linux
}

do_install() {
    # binary
    install -m 0755 -d ${D}${optdir}/lora-basic-station
    
    # Pmonitor service configuration files
    pmonitor_service_install ${WORKDIR}/lora-basic-station.yml
}

do_install_append_lorix-one() {
    install -m 0744 ${S}/build-lorix-std/bin/station ${D}${optdir}/lora-basic-station/lora-basic-station
}

FILES_${PN} += "${optdir}"
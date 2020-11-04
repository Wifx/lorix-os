SUMMARY = "LoRa SX1301 based gateway"
DESCRIPTION = "LoRa SX1301 based gateway library and tools."

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=e0426896daac8683a0e3112349e6124e"
PR = "r0"

SRC_URI = " \
    git://github.com/Lora-net/lora_gateway.git;protocol=git;tag=v${PV} \
    file://LICENSE \
    "
S = "${WORKDIR}/git"

PACKAGES += "libloragw libloragw-dev libloragw-staticdev"
PROVIDES += "libloragw libloragw-dev libloragw-staticdev"

EXTRA_OEMAKE = " \
    'CC=${CC}' 'CFLAGS=${CFLAGS} \
    -I${S}/util_pkt_logger/inc \
    -I${S}/libloragw -I${S}/libloragw/inc' \
    'BUILDDIR=${S}' \
"

do_install () {
    # library
    install -m 0755 -d ${D}${libdir}/libloragw
    install -m 0644 ${S}/libloragw/libloragw.a ${D}${libdir}/libloragw/libloragw.a

    # header files
    install -m 0755 -d ${D}${libdir}/libloragw/inc
    install -m 0644 -D ${S}/libloragw/inc/* ${D}${libdir}/libloragw/inc
    install -m 0644 ${S}/libloragw/library.cfg ${D}${libdir}/libloragw/library.cfg
}

FILES_${PN}-dev = ""
FILES_libloragw-dev += " \
    ${libdir}/libloragw/inc/* \
"
FILES_libloragw-staticdev += " \
    ${libdir}/libloragw/*.cfg \
    ${libdir}/libloragw/libloragw.a \
"

PACKAGE_ARCH = "${MACHINE_ARCH}"

DESCRIPTION = "Driver/HAL to build a gateway using a concentrator board based on Semtech SX1301"
HOMEPAGE = "https://github.com/Lora-net/lora_gateway"
PRIORITY = "optional"
LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://LICENSE;md5=a2bdef95625509f821ba00460e3ae0eb"
PR = "r8"
PRR = "r2"

SRC_URI = "\
    git://github.com/brocaar/lora_gateway.git;protocol=git;tag=v${PV}${PRR} \
    file://0001-Restore-default-SPI-path-to-keep-tests-and-utils-wor.patch \
    file://library.cfg \
"

S = "${WORKDIR}/git"

DEPENDS = "\
    clang-native \
"
# Use clang as we will be linking against this library using Rust. With the
# default gcc we get link errors.
TOOLCHAIN = "clang"

CFLAGS += "-Iinc -I."

DIR_UTILS = "/opt/${PN}/gateway-utils"
DIR_TESTS = "/opt/${PN}/gateway-tests"

do_configure_append() {
    cp ${WORKDIR}/library.cfg ${S}/libloragw/library.cfg
}

do_compile() {
    oe_runmake
}

do_install() {
    # library
    install -m 0755 -d                          ${D}${libdir}/libloragw-sx1301
    install -m 0644 ${S}/libloragw/libloragw.a  ${D}${libdir}/libloragw-sx1301.a
    install -m 0644 ${S}/libloragw/library.cfg  ${D}${libdir}/libloragw-sx1301/library.cfg

    # header files
    install -m 0755 -d                          ${D}${includedir}/libloragw-sx1301
    install -m 0644 ${S}/libloragw/inc/*        ${D}${includedir}/libloragw-sx1301
    
    # Support for udp-packet-forwarder
    install -m 0644 ${S}/libloragw/libloragw.a  ${D}${libdir}/libloragw-sx1301/libloragw.a
    install -m 0755 -d                          ${D}${libdir}/libloragw-sx1301/inc
    install -m 0644 ${S}/libloragw/inc/*        ${D}${libdir}/libloragw-sx1301/inc

    # Install utils
    install -d ${D}/${DIR_UTILS}
    install -m 0755 util_pkt_logger/util_pkt_logger             ${D}/${DIR_UTILS}
    install -m 0755 util_pkt_logger/*.json                      ${D}/${DIR_UTILS}
    install -m 0755 util_spectral_scan/util_spectral_scan       ${D}/${DIR_UTILS}
    install -m 0755 util_spi_stress/util_spi_stress             ${D}/${DIR_UTILS}
    install -m 0755 util_tx_test/util_tx_test                   ${D}/${DIR_UTILS}
    install -m 0755 util_tx_continuous/util_tx_continuous       ${D}/${DIR_UTILS}
    install -m 0755 util_lbt_test/util_lbt_test                 ${D}/${DIR_UTILS}

    # Install tests
    install -d ${D}/${DIR_TESTS}
    install -m 0755 libloragw/test_*                            ${D}/${DIR_TESTS}
}

PACKAGES += "${PN}-utils ${PN}-tests"

PACKAGE_ARCH = "${MACHINE_ARCH}"

FILES_${PN}-utils = "${DIR_UTILS}"
FILES_${PN}-tests = "${DIR_TESTS}"

FILES_${PN}-dev = "${includedir}"
FILES_${PN}-staticdev = "${libdir}"

INSANE_SKIP_${PN}-utils = "ldflags"
INSANE_SKIP_${PN}-tests = "ldflags"

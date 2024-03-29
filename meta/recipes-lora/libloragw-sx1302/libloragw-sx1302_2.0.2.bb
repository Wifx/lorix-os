DESCRIPTION = "Driver/HAL to build a gateway using a concentrator board based on Semtech SX1302"
HOMEPAGE = "https://github.com/Lora-net/sx1302_hal"
PRIORITY = "optional"
LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/BSD;md5=3775480a712fc46a69647678acb234cb"
PR = "r10"

SRC_URI = "\
    git://github.com/Lora-net/sx1302_hal.git;protocol=https;tag=V${PV} \
    file://0001-test-change-stdout-err-to-line-buffered.patch \
    file://library.cfg \
    file://0001-test_loragw_hal_tx-enable-CRC-for-LoRa-TX-packets-by.patch \
    file://0002-test_loragw_hal_tx-add-optional-argument-to-disable-.patch \
    file://reset_lgw.sh \
"

COMPATIBLE_MACHINE_FEATURE = "sx1302"

# depends on lora-concentrator-reset script
RDEPENDS_${PN}-utils += "lora-concentrator"
RDEPENDS_${PN}-tests += "lora-concentrator"
RDEPENDS_${PN}-tests-ext += "${PN}-tests"

S = "${WORKDIR}/git"

# Use clang as we will be linking against this library using Rust. With the
# default gcc we get link errors.
TOOLCHAIN = "clang"

CFLAGS += "-I inc -I ../libtools/inc"

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
    install -m 0755 -d                          ${D}${libdir}/libloragw-sx1302
    install -m 0644 ${S}/libloragw/library.cfg  ${D}${libdir}/libloragw-sx1302/library.cfg
    install -m 0644 ${S}/libloragw/libloragw.a  ${D}${libdir}/libloragw-sx1302.a
    install -m 0644 ${S}/libtools/*.a           ${D}${libdir}/
    
    # header files
    install -m 0755 -d                         ${D}${includedir}/libloragw-sx1302
    install -m 0644 ${S}/libloragw/inc/*       ${D}${includedir}/libloragw-sx1302

    # essential tools
    install -m 0644 ${S}/libtools/*.a           ${D}${libdir}
    install -m 0644 ${S}/libtools/inc/*         ${D}${includedir}
    
    # Install utils
    install -d ${D}/${DIR_UTILS}
    install -m 0755 ${S}/util_chip_id/chip_id                        ${D}/${DIR_UTILS}
    install -m 0755 ${S}/util_net_downlink/net_downlink              ${D}/${DIR_UTILS}
    install -m 0755 ${S}/packet_forwarder/lora_pkt_fwd               ${D}/${DIR_UTILS}
    install -m 0755 ${S}/packet_forwarder/global_conf.json.sx1250.*  ${D}/${DIR_UTILS}
    install -m 0755 ${WORKDIR}/reset_lgw.sh                          ${D}/${DIR_UTILS}

    # Install tests
    install -d ${D}/${DIR_TESTS}
    install -m 0755 ${S}/libloragw/test_*                            ${D}/${DIR_TESTS}
    install -m 0755 ${WORKDIR}/reset_lgw.sh                          ${D}/${DIR_TESTS}
}

PACKAGES =+ "${PN}-utils ${PN}-tests ${PN}-tests-ext"

PACKAGE_ARCH = "${MACHINE_ARCH}"

FILES_${PN}-utils = "${DIR_UTILS}"
FILES_${PN}-tests = " \
    ${DIR_TESTS}/reset_lgw.sh \
    ${DIR_TESTS}/test_loragw_hal_rx \
    ${DIR_TESTS}/test_loragw_hal_tx \
"
FILES_${PN}-tests-ext = "${DIR_TESTS}"

FILES_${PN}-dev = "${includedir}"
FILES_${PN}-staticdev = "${libdir}"

INSANE_SKIP_${PN}-utils = "ldflags"
INSANE_SKIP_${PN}-tests = "ldflags"

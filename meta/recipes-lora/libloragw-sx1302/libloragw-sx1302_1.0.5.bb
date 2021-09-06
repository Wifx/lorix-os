DESCRIPTION = "Driver/HAL to build a gateway using a concentrator board based on Semtech SX1302"
HOMEPAGE = "https://github.com/Lora-net/sx1302_hal"
PRIORITY = "optional"
LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/BSD;md5=3775480a712fc46a69647678acb234cb"
PR = "r10"

SRC_URI = "\
    git://github.com/Lora-net/sx1302_hal.git;protocol=git;tag=V${PV} \
    file://library.cfg \
"

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
    install -m 0644 ${S}/libloragw/libloragw.a  ${D}${libdir}/libloragw-sx1302.a
    install -m 0644 ${S}/libloragw/library.cfg  ${D}${libdir}/libloragw-sx1302/library.cfg
    
    # header files
    install -m 0755 -d                         ${D}${includedir}/libloragw-sx1302
    install -m 0644 ${S}/libloragw/inc/*       ${D}${includedir}/libloragw-sx1302

    # Install utils
    install -d ${D}/${DIR_UTILS}
    install -m 0755 util_chip_id/chip_id                        ${D}/${DIR_UTILS}
    install -m 0755 util_net_downlink/net_downlink              ${D}/${DIR_UTILS}
    install -m 0755 packet_forwarder/lora_pkt_fwd               ${D}/${DIR_UTILS}
    install -m 0755 packet_forwarder/global_conf.json.sx1250.*  ${D}/${DIR_UTILS}

    # Install tests
    install -d ${D}/${DIR_TESTS}
    install -m 0755 libloragw/test_*                            ${D}/${DIR_TESTS}
}

PACKAGES += "${PN}-utils ${PN}-tests"

FILES_${PN}-utils = "${DIR_UTILS}"
FILES_${PN}-tests = "${DIR_TESTS}"

FILES_${PN}-dev = "${includedir}"
FILES_${PN}-staticdev = "${libdir}"

INSANE_SKIP_${PN}-utils = "ldflags"
INSANE_SKIP_${PN}-tests = "ldflags"
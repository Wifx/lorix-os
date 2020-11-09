DESCRIPTION = "Driver/HAL to build a gateway using a concentrator board based on Semtech SX1301"
HOMEPAGE = "https://github.com/Lora-net/lora_gateway"
PRIORITY = "optional"
LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://LICENSE;md5=a2bdef95625509f821ba00460e3ae0eb"
PR = "r8"
PRR = "r2"

SRC_URI = "\
    git://github.com/brocaar/lora_gateway.git;protocol=git;tag=v${PV}${PRR} \
"

S = "${WORKDIR}/git"

# Use clang as we will be linking against this library using Rust. With the
# default gcc we get link errors.
TOOLCHAIN = "clang"

CFLAGS += "-Iinc -I."

do_compile() {
    oe_runmake
}

do_install() {
    # library
    install -m 0755 -d ${D}${libdir}/libloragw
    install -m 0644 ${S}/libloragw/libloragw.a ${D}${libdir}/libloragw/libloragw.a

    # header files
    install -m 0755 -d ${D}${includedir}
    install -m 0644 -D ${S}/libloragw/inc/* ${D}${includedir}
    install -m 0644 ${S}/libloragw/library.cfg ${D}${libdir}/libloragw/library.cfg
}

PACKAGES += "${PN}-utils ${PN}-utils-dbg"

FILES_${PN}-dev = "${includedir}"
FILES_${PN}-staticdev = "${libdir}"

INSANE_SKIP_${PN}-utils = "ldflags"

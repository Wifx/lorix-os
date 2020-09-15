HOMEPAGE = "https://www.chirpstack.io/"
DESCRIPTION = "ChirpStack Concentratord"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=99e425257f8a67b7efd81dc0009ed8ff"

SRC_URI = "\
    git://github.com/brocaar/chirpstack-concentratord.git;protocol=git;tag=v${PV} \
    file://0001-removed-sx1302.patch \
"
DEPENDS = "\
    clang-native \
    libloragw-sx1301 \
"

inherit cargo

INITSCRIPT_NAME = "chirpstack-concentratord"
INITSCRIPT_PARAMS = "defaults"

S = "${WORKDIR}/git"

export BINDGEN_EXTRA_CLANG_ARGS="-I${STAGING_INCDIR}"

do_install() {
    install -d ${D}${bindir}

    if [ "${CARGO_BUILD_TYPE}" = "--release" ]; then
        local cargo_bindir="${CARGO_RELEASE_DIR}"
    else
        local cargo_bindir="${CARGO_DEBUG_DIR}"
    fi


    #install -m 0755 ${cargo_bindir}/chirpstack-concentratord-sx1301 ${D}${bindir}
    #install -m 0755 ${cargo_bindir}/chirpstack-concentratord-sx1302 ${D}${bindir}
    #install -m 0755 ${cargo_bindir}/gateway-id ${D}${bindir}
}

PACKAGES += "${PN}-sx1301"

FILES_${PN} = "${sysconfdir} ${bindir}/gateway-id"
FILES_${PN}-sx1301 = "${bindir}/chirpstack-concentratord-sx1301"

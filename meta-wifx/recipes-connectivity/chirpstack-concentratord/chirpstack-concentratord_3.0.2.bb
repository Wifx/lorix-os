HOMEPAGE = "https://www.chirpstack.io/"
DESCRIPTION = "ChirpStack Concentratord"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=99e425257f8a67b7efd81dc0009ed8ff"

SRC_URI = "\
    git://github.com/brocaar/chirpstack-concentratord.git;protocol=git;tag=v${PV} \
    file://chirpstack-concentratord.yml \
    file://config.toml \
"
DEPENDS = "\
    libloragw-sx1301 \
    libloragw-sx1302 \
    clang-native \
"
RPROVIDES_${PN} += "virtual/lora-packet-forwarder"

inherit cargo pmonitor

CONF_DIR = "${sysconfoptdir}/chirpstack-concentratord"
S = "${WORKDIR}/git"

export BINDGEN_EXTRA_CLANG_ARGS="-I${STAGING_INCDIR}"

do_install() {


    if [ "${CARGO_BUILD_TYPE}" = "--release" ]; then
        local cargo_bindir="${CARGO_RELEASE_DIR}"
    else
        local cargo_bindir="${CARGO_DEBUG_DIR}"
    fi

    install -m 0755 -d ${D}${optdir}/chirpstack-concentratord
    install -m 0755 -d ${D}${CONF_DIR}

    # gateway-id is only for the SX1302
    # TODO: manage its installation
    #install -m 0755 ${cargo_bindir}/gateway-id ${D}${optdir}/chirpstack-concentratord

    install -m 0644 ${WORKDIR}/config.toml ${D}${CONF_DIR}/config.toml

    pmonitor_service_install ${WORKDIR}/chirpstack-concentratord.yml

}

do_install_lorix_one() {
    install -m 0755 ${cargo_bindir}/chirpstack-concentratord-sx1301 ${D}${optdir}/chirpstack-concentratord/chirpstack-concentratord
}

do_install_append_lorix-one-256() {
    do_install_lorix_one
}

do_install_append_lorix-one-512() {
    do_install_lorix_one
}

#FILES_${PN} += "${optdir}/chirpstack-concentratord/gateway-id"
FILES_${PN} += "${optdir}/chirpstack-concentratord/chirpstack-concentratord"
PACKAGE_ARCH = "${MACHINE_ARCH}"

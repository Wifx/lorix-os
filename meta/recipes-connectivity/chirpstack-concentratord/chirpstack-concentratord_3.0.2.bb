HOMEPAGE = "https://www.chirpstack.io/"
DESCRIPTION = "ChirpStack Concentratord"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=99e425257f8a67b7efd81dc0009ed8ff"

SRC_URI = "\
    git://github.com/brocaar/chirpstack-concentratord.git;protocol=git;tag=v${PV} \
    file://chirpstack-concentratord.yml \
    file://config.toml \
"

DEPENDS = " \
    clang-native \
"

DEPENDS += "${@bb.utils.contains('MACHINE_FEATURES', 'sx1301', 'libloragw-sx1301', '', d)}"
DEPENDS += "${@bb.utils.contains('MACHINE_FEATURES', 'sx1302', 'libloragw-sx1302', '', d)}"

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


    # gateway-id is only for the SX1302
    # TODO: manage its installation
    #install -m 0755 ${cargo_bindir}/gateway-id ${D}${optdir}/chirpstack-concentratord

    install -m 0755 -d ${D}${CONF_DIR}
    install -m 0644 ${WORKDIR}/config.toml ${D}${CONF_DIR}/config.toml

    pmonitor_service_install ${WORKDIR}/chirpstack-concentratord.yml
}

do_install_append() {
    install -m 0755 -d ${D}${optdir}/chirpstack-concentratord

    if [ "${@bb.utils.contains('MACHINE_FEATURES', 'sx1301', 'true', 'false', d)}" = "true" ]; then
        concentrator="sx1301"
    fi
    
    if [ "${@bb.utils.contains('MACHINE_FEATURES', 'sx1302', 'true', 'false', d)}" = "true" ]; then
        if [ -z $concentrator ]; then
            bbfatal "Cannot have both sx1301 and sx1302"
        fi
        concentrator="sx1302"
    fi

    case $concentrator in
        "sx1301")
            install -m 0755 ${cargo_bindir}/chirpstack-concentratord-sx1301 ${D}${optdir}/chirpstack-concentratord/chirpstack-concentratord
            break
            ;;

        "sx1302")
            install -m 0755 ${cargo_bindir}/chirpstack-concentratord-sx1302 ${D}${optdir}/chirpstack-concentratord/chirpstack-concentratord
            break
            ;;

        *)
            bbfatal "concentratord needs either sx1301 or sx1302"
            ;;
    esac
}

FILES_${PN} += " \
    ${optdir}/chirpstack-concentratord/chirpstack-concentratord \
    ${CONF_DIR}/config.toml \
"
PACKAGE_ARCH = "${MACHINE_ARCH}"

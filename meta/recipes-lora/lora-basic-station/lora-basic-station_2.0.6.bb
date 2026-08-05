SUMMARY = "The Basic Station is a LoRaWAN packet forwarder"
DESCRIPTION = "LoRa Basic Station"
HOMEPAGE = "https://doc.sm.tc/station/"
AUTHOR = "Semtech LoRa Basics"

LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=a00b6155c30853bb390ec59ba94e2b06"

PACKAGE_ARCH = "${MACHINE_ARCH}"

SRC_URI = "git://github.com/lorabasics/basicstation.git;protocol=https;branch=master"
SRCREV = "ba4f85d80a438a5c2b659e568cd2d0f0de08e5a7"

SRC_URI += " \
    file://lora-basic-station.yml \
    file://0001-editable-toolchain-path.patch \
    file://0002-handle-router-config-on-unknown-region.patch \
    file://0003-configure-tcp-user-timeout.patch \
"

SRC_URI:append:lorix-one = " \
    file://setup-lorix.gmk \
    file://resources-lorix-one/8XX/A/station_2dBi.conf \
    file://resources-lorix-one/8XX/A/station_3dBi.conf \
    file://resources-lorix-one/8XX/A/station_4dBi.conf \
    file://resources-lorix-one/8XX/A/station_5dBi.conf \
    file://resources-lorix-one/9XX/A/station_2dBi.conf \
    file://resources-lorix-one/9XX/A/station_3dBi.conf \
    file://resources-lorix-one/9XX/A/station_4dBi.conf \
    file://resources-lorix-one/9XX/A/station_5dBi.conf \
"

SRC_URI:append:l1 = " \
    file://setup-l1.gmk \
    file://resources-l1/8XX/A/station_2dBi.conf \
    file://resources-l1/8XX/A/station_3dBi.conf \
    file://resources-l1/8XX/A/station_4dBi.conf \
    file://resources-l1/8XX/A/station_5dBi.conf \
    file://resources-l1/8XX/B/station_2dBi.conf \
    file://resources-l1/8XX/B/station_3dBi.conf \
    file://resources-l1/8XX/B/station_4dBi.conf \
    file://resources-l1/8XX/B/station_5dBi.conf \
    file://resources-l1/9XX/A/station_2dBi.conf \
    file://resources-l1/9XX/A/station_3dBi.conf \
    file://resources-l1/9XX/A/station_4dBi.conf \
    file://resources-l1/9XX/A/station_5dBi.conf \
    file://resources-l1/9XX/B/station_2dBi.conf \
    file://resources-l1/9XX/B/station_3dBi.conf \
    file://resources-l1/9XX/B/station_4dBi.conf \
    file://resources-l1/9XX/B/station_5dBi.conf \
"

# Workaround for network access issue during compile step
# this needs to be fixed in the recipes buildsystem to move
# this such that it can be accomplished during do_fetch task
do_compile[network] = "1"

# At the moment, the library are compiled directly from package sources
#DEPENDS += "libloragw mbedtls"

inherit pmonitor

RDEPENDS:${PN} += "lora-concentrator"

S = "${WORKDIR}/git"

do_configure() {
    cp -f ${WORKDIR}/setup-*.gmk ${S}
}

do_configure:append:lorix-one() {
    path="${S}/deps/lgw"
    # copy existing lgw linux patch for the lorix
    cp -f ${path}/v5.0.1-linux.patch ${path}/v5.0.1-lorix.patch
}

do_configure:append:l1() {
    path="${S}/deps/lgw1302"
    # copy existing lgw linux patch for the L1
    cp -f ${path}/V2.1.0-corecell.patch ${path}/V2.1.0-l1.patch
}

TARGET_CC_ARCH += "${LDFLAGS}"

do_compile:lorix-one() {
    make platform=lorix variant=std ARCH.lorix=${TARGET_SYS}
}

do_compile:l1() {
    make platform=l1 variant=std \
        ARCH.l1=${TARGET_SYS} \
        TOOLCHAIN=${STAGING_BINDIR_TOOLCHAIN} \
        CFG.${TARGET_SYS}=linux
}

do_install() {
    # binary
    install -m 0755 -d ${D}${optdir}/lora-basic-station
    
    # Pmonitor service configuration files
    pmonitor_service_install ${WORKDIR}/lora-basic-station.yml
}

do_install:append:lorix-one() {
    install -m 0744 ${S}/build-lorix-std/bin/station ${D}${optdir}/lora-basic-station/lora-basic-station

    # configuration files
    install -m 0755 -d ${D}${sysconfoptdir}/lora-basic-station/config
    cd ${WORKDIR}/resources-lorix-one
    for file in $(find . -type f -name '*.conf'); do
        install -m 0644 -D "${WORKDIR}/resources-lorix-one/$file" "${D}${sysconfoptdir}/lora-basic-station/config/$file"
    done
}

do_install:append:l1() {
    install -m 0744 ${S}/build-l1-std/bin/station ${D}${optdir}/lora-basic-station/lora-basic-station

    # configuration files
    install -m 0755 -d ${D}${sysconfoptdir}/lora-basic-station/config
    cd ${WORKDIR}/resources-l1
    for file in $(find . -type f -name '*.conf'); do
        install -m 0644 -D "${WORKDIR}/resources-l1/$file" "${D}${sysconfoptdir}/lora-basic-station/config/$file"
    done
}

pkg_postinst_ontarget:${PN} () {
    # Update gateway ID in config
    file="${sysconfoptdir}/lora-basic-station/gateway-id"

    if [ ! -f "$file" ]; then
        # retrieve gateway ID from machine-info
        GWID=$(machine-info read "LORA_GATEWAY_ID")
        echo "$GWID" > "$file"
        echo "Gateway ID set to "$GWID" in file "$file
    else
        echo "Gateway ID already defined"
    fi
}

FILES:${PN} += "${optdir}"

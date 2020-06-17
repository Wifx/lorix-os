SUMMARY = "Basic Station hardware related configuration files"
DESCRIPTION = "Set of hardware configuration file for the Basic Station"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=83564c4ad755d0edeaa1ba4b3918b365"
PR = "r0"

SRC_URI = " \
    file://LICENSE \
"
SRC_URI_append_lorix-one-256 = " file://resources-lorix-one"
SRC_URI_append_lorix-one-512 = " file://resources-lorix-one"

do_install_lorix_one() {
    # configuration files
    install -m 0755 -d ${D}${sysconfoptdir}/lora-basic-station/config
    cd ${WORKDIR}/resources-lorix-one
    for file in $(find . -type f -name '*.conf'); do
        install -m 0644 -D "${WORKDIR}/resources-lorix-one/$file" "${D}${sysconfoptdir}/lora-basic-station/config/$file"
    done
}

do_install_append_lorix-one-256() {
    do_install_lorix_one
}

do_install_append_lorix-one-512() {
    do_install_lorix_one
}

PACKAGE_ARCH = "${MACHINE_ARCH}"

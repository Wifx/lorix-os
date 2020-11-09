SUMMARY = "UDP Packet Forwarder hardware related configuration files"
DESCRIPTION = "Set of hardware configuration file for the UDP Packet Forwarder"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=83564c4ad755d0edeaa1ba4b3918b365"
PR = "r0"

SRC_URI = " \
    file://LICENSE \
"

SRC_URI_append_lorix-one = " file://resources-lorix-one"

do_install_append_lorix-one() {
    # configuration files
    install -m 0755 -d ${D}${sysconfoptdir}/udp-packet-forwarder/hardware
    cd ${WORKDIR}/resources-lorix-one/hardware
    for file in $(find . -type f -name '*.json' -o -name '*.json.sha256'); do
        install -m 0644 -D "${WORKDIR}/resources-lorix-one/hardware/$file" "${D}${sysconfoptdir}/udp-packet-forwarder/hardware/$file"
    done
}

PACKAGE_ARCH = "${MACHINE_ARCH}"

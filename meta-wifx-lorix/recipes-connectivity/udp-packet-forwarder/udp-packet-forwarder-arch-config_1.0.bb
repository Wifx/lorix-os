SUMMARY = "UDP Packet Forwarder hardware related configuration files"
DESCRIPTION = "Set of hardware configuration file for the UDP Packet Forwarder"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=83564c4ad755d0edeaa1ba4b3918b365"
PR = "r0"

RDEPENDS_${PN} += "update-gwid"

SRC_URI = " \
    file://LICENSE \
    file://resources-lorix \
"
SRC_URI_append_lorix-one-256 = " file://resources-lorix-one"
SRC_URI_append_lorix-one-512 = " file://resources-lorix-one"

do_install() {
    # install channels conf files
    install -m 0755 -d ${D}${sysconfoptdir}/udp-packet-forwarder/channels
    cd ${WORKDIR}/resources-lorix/channels
    for file in $(find . -type f -name '*.json'); do
        install -m 0644 -D "${WORKDIR}/resources-lorix/channels/$file" "${D}${sysconfoptdir}/udp-packet-forwarder/channels/$file"
    done
}

do_install_lorix_one() {
    # configuration files
    install -m 0755 -d ${D}${sysconfoptdir}/udp-packet-forwarder/hardware
    cd ${WORKDIR}/resources-lorix-one/hardware
    for file in $(find . -type f -name '*.json' -o -name '*.json.sha256'); do
        install -m 0644 -D "${WORKDIR}/resources-lorix-one/hardware/$file" "${D}${sysconfoptdir}/udp-packet-forwarder/hardware/$file"
    done
}

do_install_append_lorix-one-256() {
    do_install_lorix_one
}

do_install_append_lorix-one-512() {
    do_install_lorix_one
}

pkg_postinst_ontarget_${PN} () {
    if [ -z "$1" ]; then
        # execute only on first boot

        # Update gateway ID in general config files
        cd ${sysconfoptdir}/udp-packet-forwarder/gateway
        for file in $(find . -type f -name '*.json' -o -name '*.json.sample'); do
            update-gwid "$file"
        done
    fi
}

PACKAGE_ARCH = "${MACHINE_ARCH}"

SUMMARY = "Machine management files for the LORIX family products"
DESCRIPTION = "Provides the LORIX management set of tools."
AUTHOR = "Wifx Sàrl"
SECTION = "base"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=83564c4ad755d0edeaa1ba4b3918b365"

SRC_URI = " \
    file://LICENSE \
    file://.machine-functions \
    file://machine-functions \
    file://20-spi.rules \
    file://10-sd-card-automount.rules \
"

PR = "r0"
S = "${WORKDIR}"

INHIBIT_DEFAULT_DEPS = "1"
do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"

RDEPENDS_${PN} += "machine-info"

osdir = "${sysconfdir}/os"

do_install () {
    install -d ${D}${osdir}
    install -m 0600 ${WORKDIR}/.machine-functions ${D}${osdir}/.machine-functions
    install -m 0700 ${WORKDIR}/machine-functions ${D}${osdir}/machine-functions

    # Install SPI fix udev rule
    install -m 755 -d ${D}${sysconfdir}/udev/rules.d
    install -m 644 ${WORKDIR}/20-spi.rules ${D}${sysconfdir}/udev/rules.d/20-spi.rules

    # Install SD automount rule
    install -m 644 ${WORKDIR}/10-sd-card-automount.rules ${D}${sysconfdir}/udev/rules.d/10-sd-card-automount.rules
}

pkg_postinst_ontarget_lorix_one () {
    if [ -z "$1" ]; then
        # execute only on first boot

        if [ -e /sys/class/net/eth0/address ]; then
            # Construct the hostname based on last 3 Bytes of eth0 MAC address
            mac=$(cat /sys/class/net/eth0/address)
            id=$(echo $mac | awk -F':' '{print $4$5$6}')
            echo "lorix-one-$id" > /etc/hostname
            # Set LORIX One hostname to "lorix-one-xxxxxx" to have unique hostname (for mDNS for example)
        else
            echo "lorix-one" > /etc/hostname
        fi
    fi
}

pkg_postinst_ontarget_l1 () {
    if [ -z "$1" ]; then
        # execute only on first boot

        # get lower case serial
        SERIAL_LABEL=$(machine-info --field "PRODUCT_SERIAL" --noheader)

        SERIAL=$(echo "${SERIAL_LABEL//-/}" | awk '{print tolower($0)}')
        
        # Set gateway hostname to "gw<serial>" to have unique hostname (for mDNS for example)
        echo "gw$SERIAL" > /etc/hostname
    fi
}

PACKAGESPLITFUNCS_prepend = "populate_packages_lorix "
populate_packages_lorix[vardeps] += "pkg_postinst_ontarget_lorix_one pkg_postinst_ontarget_l1"

python populate_packages_lorix() {
    pkg = d.getVar('PN', True)
    machine = d.getVar('MACHINE', True)

    # Add pkg to the overrides so that it finds the OPENRC_SERVICE_pkg
    # variable.
    localdata = d.createCopy()
    localdata.prependVar("OVERRIDES", pkg + ":")

    if machine.startswith('lorix-one-'):
        postinst_ontarget = d.getVar('pkg_postinst_ontarget_%s' % pkg)
        if not postinst_ontarget:
            postinst_ontarget = '#!/bin/sh\n'
        postinst_ontarget += localdata.getVar('pkg_postinst_ontarget_lorix_one')
        d.setVar('pkg_postinst_ontarget_%s' % pkg, postinst_ontarget)

    if machine.startswith('l1'):
        postinst_ontarget = d.getVar('pkg_postinst_ontarget_%s' % pkg)
        if not postinst_ontarget:
            postinst_ontarget = '#!/bin/sh\n'
        postinst_ontarget += localdata.getVar('pkg_postinst_ontarget_l1')
        d.setVar('pkg_postinst_ontarget_%s' % pkg, postinst_ontarget)
}

FILES_${PN} += " \
    ${osdir}/* \
    ${sysconfdir}/udev/rules.d/* \
"
PACKAGE_ARCH = "${MACHINE_ARCH}"

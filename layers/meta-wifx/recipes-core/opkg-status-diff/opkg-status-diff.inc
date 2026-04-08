SUMMARY = "OPKG status diff utility"
DESCRIPTION = "A utility for working with OPKG status files, allowing you to create diffs between status files and apply patches to them."
AUTHOR = "Wifx SA"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://${WORKDIR}/git/LICENSE;md5=ab61665cc10f12f35605de28be0fe1ad"

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

inherit unpack-online-assets

STAGING_ASSETS = "${WORKDIR}/staging-assets"

# Install the fetched binary into the target rootfs staging area
do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${STAGING_ASSETS}${bindir}/opkg-status-diff ${D}${bindir}/
}

# Ensure /usr/bin is exported to the recipe sysroot for dependent recipes
SYSROOT_DIRS += "${bindir}"

# Package the binary
FILES:${PN} += "${bindir}/opkg-status-diff"

ALLOW_EMPTY:${PN} = "1"
INHIBIT_PACKAGE_INSTALL = "1"

do_install(){
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/target/armv7-unknown-linux-gnueabihf/release/opkg-status-diff ${D}${bindir}/opkg-status-diff
}

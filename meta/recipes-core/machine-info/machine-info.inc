SUMMARY = "Wifx board machine detection and information gathering util"
DESCRIPTION = "Provides a common interface over all Wifx gateway board machines \
               to detect and gather information about the material."
AUTHOR = "Wifx Sarl"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://${WORKDIR}/git/LICENSE;md5=ab61665cc10f12f35605de28be0fe1ad"

SRC_URI += "file://30-machine-info.rules"

inherit unpack-online-assets

STAGING_ASSETS = "${WORKDIR}/staging-assets"

do_install(){
    install -m 0755 -d ${D}${sbindir}
    install -m 0755 ${STAGING_ASSETS}/${sbindir}/machine-info ${D}${sbindir}/machine-info

    do_install_base
}

do_install_base(){
    # Install udev rule
    install -m 755 -d ${D}${sysconfdir}/udev/rules.d
    install -m 644 ${WORKDIR}/30-machine-info.rules ${D}${sysconfdir}/udev/rules.d/30-machine-info.rules
}

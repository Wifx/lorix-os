SUMMARY = "Wifx board Embedded Controller util"
DESCRIPTION = "Util to programm and manage the Wifx board Embedded Controller through wgw-ec driver or i2cdev."
AUTHOR = "Wifx SA"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://${WORKDIR}/git/LICENSE;md5=61619980fb3d535c679ce6ba61cb7790"

inherit unpack-online-assets

STAGING_ASSETS = "${WORKDIR}/staging-assets"

do_install_base(){
    install -m 0755 -d ${D}${sbindir}
    install -m 0755 ${STAGING_ASSETS}/${sbindir}/wgw-ec-util ${D}${sbindir}/wgw-ec-util
}

do_install(){
    do_install_base
}

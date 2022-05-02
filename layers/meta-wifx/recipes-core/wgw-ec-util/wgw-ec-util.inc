SUMMARY = "Wifx board Embedded Controller util"
DESCRIPTION = "Util to programm and manage the Wifx board Embedded Controller through wgw-ec driver or i2cdev."
AUTHOR = "Wifx Sarl"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://${WORKDIR}/git/LICENSE;md5=ab61665cc10f12f35605de28be0fe1ad"

inherit unpack-online-assets

STAGING_ASSETS = "${WORKDIR}/staging-assets"

do_install(){
    install -m 0755 -d ${D}${sbindir}
    install -m 0755 ${STAGING_ASSETS}/${sbindir}/wgw-ec-util ${D}${sbindir}/wgw-ec-util
}

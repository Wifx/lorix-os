SUMMARY = ""
DESCRIPTION = ""
AUTHOR = "Wifx Sarl"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://${WORKDIR}/git/LICENSE;md5=ab61665cc10f12f35605de28be0fe1ad"

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

inherit unpack-online-assets

STAGING_ASSETS = "${WORKDIR}/staging-assets"

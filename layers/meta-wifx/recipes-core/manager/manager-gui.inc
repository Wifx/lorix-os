SUMMARY = "LORIX Manager GUI for unified centralized management"
DESCRIPTION = "Provides the LORIX Manager web GUI files to be served by the daemon over HTTP"
AUTHOR = "Wifx Sàrl"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=7b29896a760c7f57013dc1412764b30c"

PROVIDES = "manager-gui"
RDEPENDS_${PN}  += "manager"

S = "${WORKDIR}/git"
B = "${WORKDIR}/git/dist"

inherit unpack-online-assets

do_install() {
    # GUI web files
    install -d ${D}${servicedir}/manager
    cp -r ${B}/* ${D}/${servicedir}/manager

    # Install license file into web sources directory
    install -m 0444 ${S}/LICENSE ${D}/${servicedir}/manager
}

FILES_${PN} = "${servicedir}/manager/*"

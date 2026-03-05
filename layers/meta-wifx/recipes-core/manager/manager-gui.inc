SUMMARY = "LORIX Manager GUI for unified centralized management"
DESCRIPTION = "Provides the LORIX Manager web GUI files to be served by the daemon over HTTP"
AUTHOR = "Wifx SA"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=83e8b42d279fd024a8a6e610bc43e8f6"

CVE_PRODUCT = "wifx:lorix-manager-gui"

PROVIDES = "manager-gui"
RDEPENDS:${PN}  += "manager"

S = "${WORKDIR}/git"
B = "${S}/dist"

inherit unpack-online-assets

do_install() {
    
    MANAGER_INSTALL_DIR="${D}${servicedir}/manager"
    install -d ${MANAGER_INSTALL_DIR}

    echo "Installing built GUI files to ${MANAGER_INSTALL_DIR}"
    cp -r ${B}/* ${MANAGER_INSTALL_DIR}/

    install -m 0644 ${S}/LICENSE ${MANAGER_INSTALL_DIR}/LICENSE
}

FILES:${PN} = "${servicedir}/manager/*"

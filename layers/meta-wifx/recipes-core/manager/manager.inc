SUMMARY = "LORIX Manager daemon for unified centralized management"
DESCRIPTION = "Provides the LORIX Manager daemon and REST API"
AUTHOR = "Wifx Sàrl"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://src/${GO_IMPORT}/LICENSE;md5=ffdb0a8bda31b45fc5b72d3774d715e2"

RDEPENDS_${PN} += " \
    openssl-bin \
    dbus \
    glibc \
    machine-info \
"
RRECOMMENDS_${PN} += "manager-gui mender-client networkmanager networkmanager-nmcli"

SRC_URI += " \
    file://config.toml \
    file://update.toml \
    file://api.toml \
    file://gui.toml \
    file://bash_completion \
"

# TODO: restore file-rdpes check
INSANE_SKIP_${PN} = "file-rdeps"

GO_IMPORT = "git.wifx.net/lorix/manager"

S = "${WORKDIR}/git"
B = "${WORKDIR}/build"

inherit unpack-online-assets

do_install_base() {
    # Configuration files
    install -d ${D}${sysconfdir}/manager/conf.d
    install -m 0644 ${WORKDIR}/config.toml ${D}${sysconfdir}/manager/conf.d/00-manager.toml

    # Default configuration
    install -d ${D}${sysconfdir}/manager/conf.d/00-default
    
    install -m 0644 ${WORKDIR}/update.toml ${D}${sysconfdir}/manager/conf.d/00-default/00-update.toml
    sed -i "s|@{DISTRO_FEEDS_BASE_URL}|${DISTRO_FEEDS_BASE_URL}|" ${D}${sysconfdir}/manager/conf.d/00-default/00-update.toml
    
    install -m 0644 ${WORKDIR}/api.toml ${D}${sysconfdir}/manager/conf.d/00-default/01-api.toml

    install -m 0644 ${WORKDIR}/gui.toml ${D}${sysconfdir}/manager/conf.d/00-default/02-gui.toml
    

    # Manager binary
    install -d ${D}${sbindir}
    install -m 0755 ${B}/bin/linux_arm/manager ${D}${sbindir}/managerd
    #install -m 0755 ${B}/manager ${D}${sbindir}/managerd

    # Command Line Interface shortcuts
    install -d ${D}${bindir}
    ln -snf ${sbindir}/managerd ${D}${bindir}/manager
    ln -snf ${sbindir}/managerd ${D}${bindir}/lm

    # Create certificates/keys directories
    install -m 0755 -d ${D}${sysconfdir}/manager/certs
    install -m 0700 -d ${D}${sysconfdir}/manager/keys

    # Add bash completion file
    install -d ${D}${sysconfdir}/profile.d
    install -m 0644 ${WORKDIR}/bash_completion ${D}${sysconfdir}/profile.d/manager.sh
}

do_install(){
    do_install_base
}

pkg_postinst_ontarget_${PN} () {
    # Generating auth secret key
    if [ ! -f "${sysconfdir}/manager/conf.d/00-default/01-api-secret-key.toml" ]; then
        echo -n "Generating authentification secret key...  "
        key=$(openssl rand -base64 32)

        cat <<EOM >"${sysconfdir}/manager/conf.d/00-default/01-api-secret-key.toml"
### This file is auto-generated at first boot ###

# Key used for encryption of the authentication token. All devices with the same secret share access tokens.
[api.authentication]
secretKey = "$key"
EOM

        echo "done"
    fi

    # Generating certificates
    if [ ! -f "${sysconfdir}/manager/keys/default.key" ] || [ ! -f "${sysconfdir}/manager/certs/default.crt" ]; then
        echo "Generating certificate..."
        PRODUCT_LABEL=$(machine-info -n -f "PRODUCT_LABEL")
        openssl req -new -newkey rsa:2048 -days 30 -nodes -x509 -subj "/CN=${PRODUCT_LABEL}" -keyout "${sysconfdir}/manager/keys/default.key" -out "${sysconfdir}/manager/certs/default.crt"
        chmod 600 ${sysconfdir}/manager/keys/default.key
        echo "done"
    fi
}
do_package[vardeps] += "pkg_postinst_ontarget_${PN}"

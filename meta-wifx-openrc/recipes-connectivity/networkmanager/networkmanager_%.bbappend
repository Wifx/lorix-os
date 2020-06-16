FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
    file://NetworkManager.initd \
    file://NetworkManager.confd \
    file://10-openrc-status \
    file://01-org.freedesktop.NetworkManager.settings.modify.system.rules \
"

inherit openrc

OPENRC_SERVICE_${PN} = "NetworkManager"
OPENRC_RUNLEVEL_NetworkManager = "default"

do_install_append() {
    # Install OpenRC conf script
    openrc_install_config ${WORKDIR}/NetworkManager.confd

    # Install OpenRC script
    openrc_install_script ${WORKDIR}/NetworkManager.initd

    # Install connectivity checker script
    install -d -m 755 ${D}${sysconfdir}/NetworkManager/dispatcher.d/
    install -m 755 ${WORKDIR}/10-openrc-status ${D}${sysconfdir}/NetworkManager/dispatcher.d/
    sed -i "s|@EPREFIX@||g" ${D}${sysconfdir}/NetworkManager/dispatcher.d/10-openrc-status


    # Allow users in plugdev group to modify system connections
    install -d -m 755 ${D}${datadir}/polkit-1/rules.d/
    install -m 644 ${WORKDIR}/01-org.freedesktop.NetworkManager.settings.modify.system.rules \
        ${D}${datadir}/polkit-1/rules.d/
}

FILES_${PN} += " \
    ${OPENRC_INITDIR}/NetworkManager \
    ${OPENRC_CONFDIR}/NetworkManager \
    ${sysconfdir}/NetworkManager/dispatcher.d/10-openrc-status \
    ${datadir}/polkit-1/rules.d/01-org.freedesktop.NetworkManager.settings.modify.system.rules \
"

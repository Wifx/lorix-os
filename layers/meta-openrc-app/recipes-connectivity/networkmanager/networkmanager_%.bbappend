FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
    file://NetworkManager.initd \
    file://NetworkManager.confd \
    file://usb-gadget.initd.in \
    file://10-openrc-status \
    file://01-org.freedesktop.NetworkManager.settings.modify.system.rules \
"

inherit openrc

OPENRC_SERVICE_${PN} = "NetworkManager usb-gadget"
OPENRC_SERVICE_${PN} = "NetworkManager"
OPENRC_RUNLEVEL_NetworkManager = "default"
#OPENRC_RUNLEVEL_usb-gadget = "boot"

do_install[vardeps] += "MACHINE_PRETTY_NAME"
do_install_append() {
    # Install OpenRC conf script
    openrc_install_config ${WORKDIR}/NetworkManager.confd

    # Update OpenRC init script with correct machine name
    #sed "s|@{MACHINE_TYPE}|${MACHINE_PRETTY_NAME}|" ${WORKDIR}/usb-gadget.initd.in > ${WORKDIR}/usb-gadget.initd

    # Install OpenRC script
    openrc_install_script ${WORKDIR}/NetworkManager.initd
    #openrc_install_script ${WORKDIR}/usb-gadget.initd

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
    ${OPENRC_INITDIR}/* \
    ${OPENRC_CONFDIR}/* \
    ${sysconfdir}/NetworkManager/dispatcher.d/10-openrc-status \
    ${datadir}/polkit-1/rules.d/01-org.freedesktop.NetworkManager.settings.modify.system.rules \
"

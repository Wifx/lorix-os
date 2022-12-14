SRC_URI += " \
    file://interfaces.networkmanager \
    file://backhaul.nmconnection \
    file://service.nmconnection \
    file://NetworkManager.state \
    file://00-no-systemd-resolved.conf \
    file://15-resolv.conf \
    file://20-connectivity.conf \
"

ALTERNATIVE_PRIORITY = "60"
ALTERNATIVE_${PN} = "net.interfaces"
ALTERNATIVE_LINK_NAME[net.interfaces] = "${sysconfdir}/network/interfaces"
ALTERNATIVE_TARGET[net.interfaces] = "${sysconfdir}/network/alternatives/interfaces.networkmanager"

PACKAGECONFIG ?= "nss ifupdown dnsmasq nmcli \
    ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemd', bb.utils.contains('DISTRO_FEATURES', 'x11', 'consolekit', '', d), d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'bluetooth', 'bluez5', '', d)} \
    ${@bb.utils.filter('DISTRO_FEATURES', 'wifi polkit', d)} \
"

do_install_append() {
    # Add the ifupdown atlernative file
    install -d ${D}${sysconfdir}/network/alternatives
    install -m 0644 ${WORKDIR}/interfaces.networkmanager ${D}${sysconfdir}/network/alternatives/interfaces.networkmanager

    # Install default connections and main configuration file
    install -d ${D}${sysconfdir}/NetworkManager/system-connections
    install -m 0600 ${WORKDIR}/service.nmconnection ${D}${sysconfdir}/NetworkManager/system-connections/service.nmconnection
    install -m 0600 ${WORKDIR}/backhaul.nmconnection ${D}${sysconfdir}/NetworkManager/system-connections/backhaul.nmconnection

    # Install default configuration files
    install -d ${D}${sysconfdir}/NetworkManager/conf.d
    install -m 0644 ${WORKDIR}/00-no-systemd-resolved.conf ${D}${sysconfdir}/NetworkManager/conf.d/00-no-systemd-resolved.conf
    install -m 0644 ${WORKDIR}/15-resolv.conf ${D}${sysconfdir}/NetworkManager/conf.d/15-resolv.conf
    install -m 0644 ${WORKDIR}/20-connectivity.conf ${D}${sysconfdir}/NetworkManager/conf.d/20-connectivity.conf

    # Install general state parameters
    install -m 700 -d ${D}/var/lib/NetworkManager
    install -m 644 ${WORKDIR}/NetworkManager.state ${D}/var/lib/NetworkManager/NetworkManager.state
}
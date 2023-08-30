SRC_URI += " \
    file://interfaces.networkmanager \
    file://00-no-systemd-resolved.conf \
    file://15-resolv.conf \
    file://20-connectivity.conf \
"

ALTERNATIVE_PRIORITY = "60"
ALTERNATIVE_${PN} = "net.interfaces"
ALTERNATIVE_LINK_NAME[net.interfaces] = "${sysconfdir}/network/interfaces"
ALTERNATIVE_TARGET[net.interfaces] = "${sysconfdir}/network/alternatives/interfaces.networkmanager"

PACKAGECONFIG ?= "nss ifupdown dnsmasq nmcli modemmanager \
    ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemd', bb.utils.contains('DISTRO_FEATURES', 'x11', 'consolekit', '', d), d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'bluetooth', 'bluez5', '', d)} \
    ${@bb.utils.filter('DISTRO_FEATURES', 'wifi polkit', d)} \
"

do_install_append() {
    # Add the ifupdown atlernative file
    install -d ${D}${sysconfdir}/network/alternatives
    install -m 0644 ${WORKDIR}/interfaces.networkmanager ${D}${sysconfdir}/network/alternatives/interfaces.networkmanager

    # Install default configuration files
    install -d ${D}${sysconfdir}/NetworkManager/conf.d
    install -m 0644 ${WORKDIR}/00-no-systemd-resolved.conf ${D}${sysconfdir}/NetworkManager/conf.d/00-no-systemd-resolved.conf
    install -m 0644 ${WORKDIR}/15-resolv.conf ${D}${sysconfdir}/NetworkManager/conf.d/15-resolv.conf
    install -m 0644 ${WORKDIR}/20-connectivity.conf ${D}${sysconfdir}/NetworkManager/conf.d/20-connectivity.conf

    # Replace original 85-nm-unmanaged.rules files to manage gadget interfaces
    if [ -e ${D}/lib/udev/rules.d/85-nm-unmanaged.rules ]; then
        sed -e '/ENV{DEVTYPE}=="gadget"\,\ ENV{NM_UNMANAGED}="1"/ s/^#*/#/' -i ${D}/lib/udev/rules.d/85-nm-unmanaged.rules
    fi
}
# Copyright (c) 2022, Wifx Sarl <info@iot.wifx.net>
# All rights reserved.

SRC_URI += " \
    file://interfaces.networkmanager \
    file://00-no-systemd-resolved.conf \
    file://15-resolv.conf \
    file://20-connectivity.conf \
    file://01-vpn-autoconnect.sh \
    file://02-vpn-reconnect.sh \
    file://vpn-reconnect.cron \
    file://0001-service-provider-add-optionnal-operator-name-filter-.patch \
    file://0002-broadband-modem-fix-autoconfig-for-roaming-condition.patch \
    file://0003-gsm-settings-fix-EPS-bearer-password-not-handled-if-.patch \
    file://0004-broadband-modem-improve-APN-autoconfig-with-operator.patch \
    file://0005-Squashed-src-n-dhcp4-changes-from-2707213e3e.0d4dcc9.patch \
    file://0006-dhcp-Fix-ciaddr-field-to-comply-with-RFC2131.patch \
"

inherit update-alternatives

ALTERNATIVE_PRIORITY = "60"
ALTERNATIVE:${PN}-daemon = "net-interfaces"
ALTERNATIVE_LINK_NAME[net-interfaces] = "${sysconfdir}/network/interfaces"
ALTERNATIVE_TARGET[net-interfaces] = "${sysconfdir}/network/interfaces.networkmanager"

DEPENDS += " \
    modemmanager \
    cronie \
    udev \
"

RDEPENDS:${PN} += " \
    udev \
"

RDEPENDS:${PN}-daemon += " \
    cronie \
"

PACKAGECONFIG:append = " \
    ${@bb.utils.contains('MACHINE_FEATURES', 'wwan', 'modemmanager', '', d)} \
"

# Replace default crypto lib, nss (8MB!!!) by gnutls (1.2MB)
PACKAGECONFIG:remove = "nss"
PACKAGECONFIG:append = " gnutls"

do_install:append() {
    # Add the ifupdown atlernative file
    install -d ${D}${sysconfdir}/network
    install -m 0644 ${WORKDIR}/interfaces.networkmanager ${D}${sysconfdir}/network/interfaces.networkmanager
    
    # Install default configuration files
    install -d ${D}${sysconfdir}/NetworkManager/conf.d
    install -m 0644 ${WORKDIR}/00-no-systemd-resolved.conf ${D}${sysconfdir}/NetworkManager/conf.d/00-no-systemd-resolved.conf
    install -m 0644 ${WORKDIR}/15-resolv.conf ${D}${sysconfdir}/NetworkManager/conf.d/15-resolv.conf
    install -m 0644 ${WORKDIR}/20-connectivity.conf ${D}${sysconfdir}/NetworkManager/conf.d/20-connectivity.conf

    # Install dispatcher files
    install -d ${D}${sysconfdir}/NetworkManager/dispatcher.d
    install -m 0755 ${WORKDIR}/01-vpn-autoconnect.sh ${D}${sysconfdir}/NetworkManager/dispatcher.d/01-vpn-autoconnect
    install -m 0755 ${WORKDIR}/02-vpn-reconnect.sh ${D}${sysconfdir}/NetworkManager/dispatcher.d/02-vpn-reconnect

    # Install vpn-reconnect cron script
    install -d ${D}${sysconfdir}/cron.d
    install -p -m 0644 ${WORKDIR}/vpn-reconnect.cron ${D}${sysconfdir}/cron.d/vpn-reconnect

    # Replace original 85-nm-unmanaged.rules files to manage gadget interfaces
    if [ -e ${D}/lib/udev/rules.d/85-nm-unmanaged.rules ]; then
        sed -e '/ENV{DEVTYPE}=="gadget"\,\ ENV{NM_UNMANAGED}="1"/ s/^#*/#/' -i ${D}/lib/udev/rules.d/85-nm-unmanaged.rules
    fi
}

CONFFILES:${PN}-daemon += " \
    ${sysconfdir}/network/interfaces.networkmanager \
    ${sysconfdir}/NetworkManager/conf.d/00-no-systemd-resolved.conf \
    ${sysconfdir}/NetworkManager/conf.d/15-resolv.conf \
    ${sysconfdir}/NetworkManager/conf.d/20-connectivity.conf \
    ${sysconfdir}/NetworkManager/dispatcher.d/01-vpn-autoconnect \
    ${sysconfdir}/NetworkManager/dispatcher.d/02-vpn-reconnect \
    ${sysconfdir}/cron.d/vpn-reconnect \
"

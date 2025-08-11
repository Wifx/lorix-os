# Copyright (c) 2025, Wifx SA <info@iot.wifx.net>
# All rights reserved.

# newnet is incompatible with NetworkManager, so we disable it
PACKAGECONFIG:remove = "newnet"

# The volatiles init script from meta-openrc doesn't handle default
# files/directories/link creation.
# Our version does.
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
    file://volatiles \
    file://volatiles.confd \
"

do_install:append() {
    # Install system related volatile configuration file
    install -m 755 -d ${D}${sysconfdir}/default/volatiles
    install -m 644 ${WORKDIR}/volatiles ${D}${sysconfdir}/default/volatiles/00_system

    # Install volatiles configuration file
    install -m 644 ${WORKDIR}/volatiles.confd ${D}${OPENRC_CONFDIR}/volatiles

    # Modify rc.conf options
    sed -i \
        -e 's|#rc_parallel="NO"|rc_parallel="YES"|' \
        -e 's|#rc_logger="NO"|rc_logger="YES"|' \
        ${D}/${sysconfdir}/rc.conf

    # Fix terminal getty configuration, we want to fix the baud rate and 
    # terminal type which needs to be set to "linux" to get color support.
    sed -i \
        -e 's|#baud=""|baud="115200"|' \
        -e 's|#term_type="linux"|term_type="linux"|' \
        ${D}${OPENRC_CONFDIR}/getty

    # Replace terminal specific getty configuration.
    # Instead of custom configuration from base openrc recipe, we copy the 
    # default one for all terminals.
    for conf in ${D}${OPENRC_CONFDIR}/getty.*; do
        rm -rf ${conf}
        install -m 644 ${D}${OPENRC_CONFDIR}/getty ${conf}

        # if terminal is USB based, we need to add a dependency on usb-gadget
        # by adding 'rc_need="usb-gadget"' into the getty configuration file.'
        if echo ${conf} | grep -qE 'ttyGS|ttyUSB|ttyACM'; then
            cat <<EOF >> ${conf}

# ttyGS|ttyUSB|ttyACM requires UART over USB through usb-gadget service
rc_need="usb-gadget"
EOF
        fi
    done
}

# Copyright (c) 2024, Wifx Sarl <info@iot.wifx.net>
# All rights reserved.

FILESEXTRAPATHS:append := "${THISDIR}/files:"

SRC_URI += " \
    file://wwan.initd \
    file://wwan-modem-check.sh \
    file://wwan-modem-check.cron \
"

inherit openrc

OPENRC_SERVICE:${PN} = "wwan"
OPENRC_RUNLEVEL:wwan = "boot"

do_install:append:l1() {
    # Install OpenRC script
    openrc_install_script ${WORKDIR}/wwan.initd

    # Install wwan-modem-check cron script
    install -d ${D}${sysconfdir}/cron.d
    install -p -m 0644 ${WORKDIR}/wwan-modem-check.cron ${D}${sysconfdir}/cron.d/wwan-modem-check

    install -d ${D}${sysconfdir}/cron.script
    install -p -m 0755 ${S}/wwan-modem-check.sh ${D}${sysconfdir}/cron.script/wwan-modem-check.sh
}

FILES:${PN} += " \
    ${OPENRC_INITDIR}/* \
    ${sysconfdir}/cron.d/wwan-modem-check \
    ${sysconfdir}/cron.script/wwan-modem-check.sh \
"
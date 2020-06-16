# Copyright (c) 2019-2020, Wifx Sàrl <info@wifx.net>
# All rights reserved.

PMONITOR_SVC_INSTALLDIR ?= "${sysconfdir}/pmonitor/services-available"
PMONITOR_SVC_ENABLEDDIR ?= "${sysconfdir}/pmonitor/services-enabled"

def use_pmonitor(d):
    if bb.utils.contains('DISTRO_FEATURES', 'pmonitor', True, False, d):
        return 'true'
    return 'false'

pmonitor_service_install() {
    local svc
    local path

    if ${@use_pmonitor(d)}; then
        [ ! -d ${D}${PMONITOR_SVC_INSTALLDIR} ] && install -m 755 -d ${D}${PMONITOR_SVC_INSTALLDIR}

        for path in $*; do
            svc=$(basename ${path})
            install -m 755 ${path} ${D}${PMONITOR_SVC_INSTALLDIR}/${svc}
        done
    fi
}

pmonitor_service_enable() {
    local svc

    if ${@use_pmonitor(d)}; then
        [ ! -d ${D}${PMONITOR_SVC_ENABLEDDIR} ] && install -m0755 -d ${D}${PMONITOR_SVC_ENABLEDDIR}

        for svc in $*; do
            ln -snf ${PMONITOR_SVC_INSTALLDIR}/${svc} ${D}${PMONITOR_SVC_ENABLEDDIR}
        done
    fi
}

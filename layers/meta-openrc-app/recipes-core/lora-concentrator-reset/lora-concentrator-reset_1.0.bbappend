FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI += " \
    file://lora-concentrator-reset-sx1301.initd \
    file://lora-concentrator-reset-sx1301.confd \
"

inherit openrc

OPENRC_SERVICE_${PN} = "lora-concentrator"
OPENRC_RUNLEVEL_lora-concentrator = "sysinit"

do_install_append() {

    if [ "${@bb.utils.contains('MACHINE_FEATURES', 'sx1301', 'true', 'false', d)}" = "true" ]; then
        CONCENTRATOR="sx1301"
    fi

    if [ -z "$CONCENTRATOR" ]; then
        bbfatal "No LoRa concentrator (sx130X) available"
    fi

    cp ${WORKDIR}/lora-concentrator-reset-$CONCENTRATOR.initd ${WORKDIR}/lora-concentrator.initd
    cp ${WORKDIR}/lora-concentrator-reset-$CONCENTRATOR.confd ${WORKDIR}/lora-concentrator.confd

    # Install OpenRC conf script
    openrc_install_config ${WORKDIR}/lora-concentrator.confd

    # Install OpenRC script
    openrc_install_script ${WORKDIR}/lora-concentrator.initd
}

FILES_${PN} += " \
    ${OPENRC_INITDIR}/lora-concentrator \
    ${OPENRC_CONFDIR}/lora-concentrator \
"

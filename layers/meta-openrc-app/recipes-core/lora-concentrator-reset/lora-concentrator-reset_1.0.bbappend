FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI += " \
    file://lora-concentrator-reset-sx1301.initd \
    file://lora-concentrator-reset-sx1301.confd \
"

inherit openrc

OPENRC_SERVICE_${PN} = "lora-concentrator"
OPENRC_RUNLEVEL_lora-concentrator-reset = "sysinit"

do_install_append() {

    cp ${WORKDIR}/lora-concentrator-reset-sx1301.initd ${WORKDIR}/lora-concentrator.initd
    cp ${WORKDIR}/lora-concentrator-reset-sx1301.confd ${WORKDIR}/lora-concentrator.confd

    # Install OpenRC conf script
    openrc_install_config ${WORKDIR}/lora-concentrator.confd

    # Install OpenRC script
    openrc_install_script ${WORKDIR}/lora-concentrator.initd
}

FILES_${PN} += " \
    ${OPENRC_INITDIR}/lora-concentrator \
    ${OPENRC_CONFDIR}/lora-concentrator \
"

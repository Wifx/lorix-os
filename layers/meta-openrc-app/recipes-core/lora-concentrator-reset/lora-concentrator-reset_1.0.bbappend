FILESEXTRAPATHS_prepend_sx1301 := "${THISDIR}/sx1301:"

SRC_URI += " \
    file://lora-concentrator-reset.confd \
    file://lora-concentrator-reset.initd \
"

inherit openrc

OPENRC_SERVICE_${PN} = "lora-concentrator"
OPENRC_RUNLEVEL_lora-concentrator = "sysinit"

do_install_append() {

    cp ${WORKDIR}/lora-concentrator-reset.initd ${WORKDIR}/lora-concentrator.initd
    cp ${WORKDIR}/lora-concentrator-reset.confd ${WORKDIR}/lora-concentrator.confd

    # Install OpenRC conf script
    openrc_install_config ${WORKDIR}/lora-concentrator.confd

    # Install OpenRC script
    openrc_install_script ${WORKDIR}/lora-concentrator.initd
}

FILES_${PN} += " \
    ${OPENRC_INITDIR}/lora-concentrator \
    ${OPENRC_CONFDIR}/lora-concentrator \
"

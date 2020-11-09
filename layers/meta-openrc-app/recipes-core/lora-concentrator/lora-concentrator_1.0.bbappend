FILESEXTRAPATHS_append := "${THISDIR}/files:"

SRC_URI += " \
    file://lora-concentrator.confd \
    file://lora-concentrator.initd \
"

inherit openrc

OPENRC_SERVICE_${PN} = "lora-concentrator"
OPENRC_RUNLEVEL_lora-concentrator = "sysinit"

do_install_append() {

    # Install OpenRC conf script
    openrc_install_config ${WORKDIR}/lora-concentrator.confd

    # Install OpenRC script
    openrc_install_script ${WORKDIR}/lora-concentrator.initd
}

FILES_${PN} += " \
    ${OPENRC_INITDIR}/lora-concentrator.confd \
    ${OPENRC_CONFDIR}/lora-concentrator.initd \
"

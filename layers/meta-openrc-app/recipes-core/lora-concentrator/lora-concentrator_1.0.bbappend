FILESEXTRAPATHS:append := "${THISDIR}/files:"

SRC_URI += " \
    file://lora-concentrator.confd \
    file://lora-concentrator.initd \
"

inherit openrc

OPENRC_SERVICE:${PN} = "lora-concentrator"
OPENRC_RUNLEVEL:lora-concentrator = "sysinit"

do_install:append() {
    # Install OpenRC conf script
    openrc_install_config ${WORKDIR}/lora-concentrator.confd

    # Install OpenRC script
    openrc_install_script ${WORKDIR}/lora-concentrator.initd
}

FILES:${PN} += " \
    ${OPENRC_CONFDIR}/lora-concentrator.confd \
    ${OPENRC_INITDIR}/lora-concentrator.initd \
"

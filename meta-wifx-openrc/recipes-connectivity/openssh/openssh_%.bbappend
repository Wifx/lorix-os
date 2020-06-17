FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
    file://sshd.initd \
    file://ssh-key.initd \
"

inherit openrc

OPENRC_SERVICE_${PN} = "ssh-key sshd"
OPENRC_RUNLEVEL_ssh-key = "boot"
OPENRC_RUNLEVEL_sshd = "default"

do_install_append() {
    # Install OpenRC script
    openrc_install_script ${WORKDIR}/ssh-key.initd
    openrc_install_script ${WORKDIR}/sshd.initd
}

FILES_${PN} += "${OPENRC_INITDIR}/ssh-key ${OPENRC_INITDIR}/sshd"

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
    file://sshd.initd \
    file://ssh-key.initd \
"

inherit openrc

OPENRC_PACKAGES = "openssh-sshd"
OPENRC_SERVICES:openssh-sshd = "ssh-key sshd"
OPENRC_RUNLEVEL:ssh-key = "boot"
OPENRC_RUNLEVEL:sshd = "default"
OPENRC_AUTO_ENABLE = "enable"

do_install:append() {
    # Install OpenRC script
    openrc_install_initd ${WORKDIR}/ssh-key.initd
    openrc_install_initd ${WORKDIR}/sshd.initd
}

FILES:${PN} += "${OPENRC_INITDIR}/ssh-key ${OPENRC_INITDIR}/sshd"

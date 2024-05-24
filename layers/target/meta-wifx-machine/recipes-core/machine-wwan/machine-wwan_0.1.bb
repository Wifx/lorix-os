SUMMARY = "Basic scripts which manages the WWAN extension card"
AUTHOR = "Wifx Sàrl"
SECTION = "base"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=d166218d6256cab6058ea8e31a8b66e8"

SRC_URI = " \
    file://LICENSE \
    file://wwan.initd \
    file://78-mm-fibocom-setup-ecm.rules \
    file://fibocom-mc610-setup-ecm.sh \
"

PR = "r0"
S = "${WORKDIR}"

INHIBIT_DEFAULT_DEPS = "1"
do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"

RDEPENDS:${PN} += "bash networkmanager modemmanager"

inherit openrc

OPENRC_SERVICE:${PN} = "wwan"
OPENRC_RUNLEVEL:wwan = "boot"

do_install:l1() {
    # Install OpenRC script
    openrc_install_script ${WORKDIR}/wwan.initd

    # Install script called by udev
    install -d ${D}${nonarch_base_libdir}/os/wwan
    install -m 0755 ${WORKDIR}/fibocom-mc610-setup-ecm.sh ${D}${nonarch_base_libdir}/os/wwan

    # Install udev rules to setup modem
    install -d ${D}${nonarch_base_libdir}/udev/rules.d
    install -m 0644 ${WORKDIR}/78-mm-fibocom-setup-ecm.rules ${D}/${nonarch_base_libdir}/udev/rules.d
    sed -i -e 's,@SCRIPT@,${nonarch_base_libdir}/os/wwan/fibocom-mc610-setup-ecm.sh,g' \
           ${D}/${nonarch_base_libdir}/udev/rules.d/78-mm-fibocom-setup-ecm.rules
}

PACKAGE_ARCH = "${MACHINE_ARCH}"

FILES:${PN} += " \
    ${OPENRC_CONFDIR}/* \
    ${nonarch_base_libdir}/os/wwan/* \
"
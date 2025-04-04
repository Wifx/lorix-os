SUMMARY = "Basic scripts which manages the WWAN extension card"
AUTHOR = "Wifx Sàrl"
SECTION = "base"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=d166218d6256cab6058ea8e31a8b66e8"

SRC_URI = " \
    file://LICENSE \
    file://78-mm-fibocom-setup-ecm.rules \
    file://fibocom-mc610-setup-ecm.sh \
    file://wwan-modem-check.sh \
    file://99-wwan-modem.rules \
    file://wwan-autoconnect-unblock.cron \
    file://wwan-autoconnect-unblock.sh \
"

PR = "r0"
S = "${WORKDIR}"

INHIBIT_DEFAULT_DEPS = "1"
do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"

DEPDENDS:${PN} += "cronie"
RDEPENDS:${PN} += "bash networkmanager modemmanager cronie"

do_install:l1() {
    # Install script called by udev
    install -d ${D}${nonarch_base_libdir}/os/wwan
    install -m 0755 ${WORKDIR}/fibocom-mc610-setup-ecm.sh ${D}${nonarch_base_libdir}/os/wwan
    install -m 0755 ${WORKDIR}/wwan-modem-check.sh ${D}${nonarch_base_libdir}/os/wwan

    # Install udev rules to setup modem
    install -d ${D}${nonarch_base_libdir}/udev/rules.d

    install -m 0644 ${WORKDIR}/78-mm-fibocom-setup-ecm.rules ${D}/${nonarch_base_libdir}/udev/rules.d
    sed -i -e 's,@SCRIPT@,${nonarch_base_libdir}/os/wwan/fibocom-mc610-setup-ecm.sh,g' ${D}/${nonarch_base_libdir}/udev/rules.d/78-mm-fibocom-setup-ecm.rules

    install -p -m 0644 ${WORKDIR}/99-wwan-modem.rules ${D}${nonarch_base_libdir}/udev/rules.d
    sed -i -e 's,@SCRIPT@,${nonarch_base_libdir}/os/wwan/wwan-modem-check.sh,g' ${D}${nonarch_base_libdir}/udev/rules.d/99-wwan-modem.rules
    sed -i -e 's,@DEVPATH@,/devices/platform/ahb/600000.ehci/usb1/1-2,g' ${D}${nonarch_base_libdir}/udev/rules.d/99-wwan-modem.rules

    install -d -m 755 ${D}${sysconfdir}/cron.d
    install -p -m 0644 ${WORKDIR}/wwan-autoconnect-unblock.cron ${D}${sysconfdir}/cron.d/wwan-autoconnect-unblock

    install -d -m 755 ${D}${sysconfdir}/cron.script
    install -p -m 0755 ${WORKDIR}/wwan-autoconnect-unblock.sh ${D}${sysconfdir}/cron.script/wwan-autoconnect-unblock.sh
}

PACKAGE_ARCH = "${MACHINE_ARCH}"

FILES:${PN} += " \
    ${nonarch_base_libdir}/os/wwan/* \
    ${nonarch_base_libdir}/udev/rules.d/* \
    ${sysconfdir}/cron.d/wwan-autoconnect-unblock \
    ${sysconfdir}/cron.script/wwan-autoconnect-unblock.sh \
"

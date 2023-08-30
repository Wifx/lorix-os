# Copyright (c) 2023, Wifx Sarl <info@iot.wifx.net>
# All rights reserved.

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
    file://78-mm-allowlist-internal-model.rules \
    file://0001-fibocom-add-support-for-SIM-PIN-PUK-remaining-enteri.patch \
    file://0002-fibocom-add-support-for-SIM-hot-swap.patch \
"

# Disable MBIM and QMI features
PACKAGECONFIG = "at"

do_install_append() {
    install -d ${D}${nonarch_base_libdir}/udev/rules.d
    install -m 0644 ${WORKDIR}/78-mm-allowlist-internal-model.rules ${D}/${nonarch_base_libdir}/udev/rules.d
}

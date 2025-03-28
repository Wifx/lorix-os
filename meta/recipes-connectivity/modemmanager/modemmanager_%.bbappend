# Copyright (c) 2023, Wifx Sarl <info@iot.wifx.net>
# All rights reserved.

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
    file://78-mm-allowlist-internal-model.rules \
    file://0001-fibocom-add-support-for-SIM-PIN-PUK-remaining-enteri.patch \
    file://0002-fibocom-add-support-for-SIM-hot-swap.patch \
    file://0003-Fix-timeout-on-CPIN-command-following-SIM-card-inser.patch \
    file://0004-fibocom-Add-supported-and-current-modes-feature.patch \
    file://0005-fibocom-cleanup-load-unlock-retries-callback.patch \
    file://0006-fibocom-add-ready-check-after-pin-unlock-in-case-of-.patch \
    file://0007-fibocom-improve-SIM-hot-swap-mecanism.patch \
"

# Disable MBIM and QMI features
PACKAGECONFIG = "at"

EXTRA_OEMESON:append = " \
    -Dplugin_altair_lte=disabled -Dplugin_anydata=disabled -Dplugin_broadmobi=disabled -Dplugin_cinterion=disabled \
    -Dplugin_dell=disabled -Dplugin_dlink=disabled -Dplugin_foxconn=disabled -Dplugin_gosuncn=disabled \
    -Dplugin_haier=disabled -Dplugin_huawei=disabled -Dplugin_intel=disabled -Dplugin_iridium=disabled \
    -Dplugin_linktop=disabled -Dplugin_longcheer=disabled -Dplugin_mbm=disabled -Dplugin_motorola=disabled \
    -Dplugin_mtk=disabled -Dplugin_nokia=disabled -Dplugin_nokia_icera=disabled -Dplugin_novatel=disabled \
    -Dplugin_novatel_lte=disabled -Dplugin_option=disabled -Dplugin_option_hso=disabled -Dplugin_pantech=disabled \
    -Dplugin_qcom_soc=disabled -Dplugin_quectel=disabled -Dplugin_samsung=disabled -Dplugin_sierra_legacy=disabled \
    -Dplugin_sierra=disabled -Dplugin_simtech=disabled -Dplugin_telit=disabled -Dplugin_thuraya=disabled \
    -Dplugin_tplink=disabled -Dplugin_ublox=disabled -Dplugin_via=disabled -Dplugin_wavecom=disabled \
    -Dplugin_x22x=disabled -Dplugin_zte=disabled \
"

do_install:append() {
    install -d ${D}${nonarch_base_libdir}/udev/rules.d
    install -m 0644 ${WORKDIR}/78-mm-allowlist-internal-model.rules ${D}/${nonarch_base_libdir}/udev/rules.d
}

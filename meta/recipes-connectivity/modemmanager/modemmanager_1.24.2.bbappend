# Copyright (c) 2023, Wifx SA <info@iot.wifx.net>
# All rights reserved.

SRC_URI += " \
    file://78-mm-allowlist-internal-model.rules \
    file://0001-fibocom-mc610-add-support-for-Fibocom-MC610-specific.patch \
    file://0002-fibocom-mc610-fix-SIM-hot-swap-handling-following-1..patch \
    file://0003-fibocom-mc610-reset-PDP-context-0-during-modem-init.patch \
    file://0004-fibocom-mc610-reduce-modem-mode-support-to-only-ECM-.patch \
    file://0005-fibocom-mc610-enhance-timeout-handling-for-Fibocom-M.patch \
    file://0006-serial-include-port-and-command-in-timeout-errors.patch \
    file://0007-fibocom-mc610-use-180s-timeout-for-all-COPS-operatio.patch \
    file://0008-3gpp-use-30s-timeout-for-CGACT-queries.patch \
    file://0009-fibocom-use-30s-timeout-for-GTRNDIS-queries.patch \
    file://0010-mc610-force-GSM_UMTS-LTE-capabilities.patch \
    file://0011-mc610-fix-GTRAT-mode-table-to-report-2G-instead-of-C.patch \
    file://0012-mc610-add-GTCCINFO-cell-info-parser-wiring-and-tests.patch \
    file://0013-mc610-run-COPS-and-GTCCINFO-on-the-secondary-AT-port.patch \
    file://0014-mc610-fibocom-increase-AT-command-and-bearer-timeout.patch \
    file://0015-mc610-retry-SIM-readiness-probing-after-hot-swap-ins.patch \
"

# Disable MBIM and QMI features
PACKAGECONFIG = "at"

EXTRA_OEMESON:append = " \
    -Dplugin_altair_lte=disabled -Dplugin_anydata=disabled -Dplugin_broadmobi=disabled \
    -Dplugin_cinterion=disabled -Dplugin_dell=disabled -Dplugin_dlink=disabled \
    -Dplugin_foxconn=disabled -Dplugin_gosuncn=disabled -Dplugin_haier=disabled \
    -Dplugin_huawei=disabled -Dplugin_intel=disabled -Dplugin_iridium=disabled \
    -Dplugin_linktop=disabled -Dplugin_longcheer=disabled -Dplugin_mbm=disabled \
    -Dplugin_motorola=disabled -Dplugin_mtk=disabled -Dplugin_nokia=disabled \
    -Dplugin_nokia_icera=disabled -Dplugin_novatel=disabled -Dplugin_novatel_lte=disabled \
    -Dplugin_option=disabled -Dplugin_option_hso=disabled -Dplugin_pantech=disabled \
    -Dplugin_qcom_soc=disabled -Dplugin_quectel=disabled -Dplugin_samsung=disabled \
    -Dplugin_sierra_legacy=disabled -Dplugin_sierra=disabled -Dplugin_simtech=disabled \
    -Dplugin_telit=disabled -Dplugin_thuraya=disabled -Dplugin_tplink=disabled \
    -Dplugin_ublox=disabled -Dplugin_via=disabled -Dplugin_wavecom=disabled \
    -Dplugin_x22x=disabled -Dplugin_zte=disabled  -Dplugin_generic=disabled \
    -Dplugin_mtk_legacy=disabled -Dplugin_netprisma=disabled \
    -Dplugin_cellient=disabled -Dplugin_rolling=disabled -Dplugin_fibocom=disabled \
    -Dplugin_fibocom_mc610=enabled \
"

do_install:append() {
    install -d ${D}${nonarch_base_libdir}/udev/rules.d
    install -m 0644 ${WORKDIR}/78-mm-allowlist-internal-model.rules ${D}/${nonarch_base_libdir}/udev/rules.d
}

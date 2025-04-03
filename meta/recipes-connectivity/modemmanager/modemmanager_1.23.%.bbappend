# Copyright (c) 2023, Wifx Sarl <info@iot.wifx.net>
# All rights reserved.

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}_1.23.95-dev:"
SRC_URI += " \
    file://78-mm-allowlist-internal-model.rules \
    file://0001-mc610-initial-implementation-of-Fibocom-MC610-specif.patch \
    file://0002-mm-broadband-modem-add-fct-to-check-if-hot-swap-cont.patch \
    file://0003-mc610-add-support-for-firmware-interface-using-fiboc.patch \
    file://0004-mc610-backport-1.22-callback-current_modes-unlock_re.patch \
    file://0005-mc610-remove-useless-check-after-SIM-unlock-modem-st.patch \
    file://0006-mc610-add-CID0-PDP-context-minimal-support.patch \
    file://0007-mc610-enforce-EPS-bearer-settings-force-flag-always-.patch \
    file://0008-mc610-fix-profile-memory-leak.patch \
    file://0009-mc610-Add-support-to-delete-profile-retrieve-profile.patch \
    file://0010-mc610-cleanup-regex-and-add-GSM-UTRAN-.-Service-URC-.patch \
    file://0011-iface-modem-3gpp-disable-profile-reload-verification.patch \
"

# Disable MBIM and QMI features
PACKAGECONFIG = "at"

EXTRA_OEMESON:append = " \
    -Dplugin_altair_lte=disabled -Dplugin_anydata=disabled -Dplugin_broadmobi=disabled -Dplugin_cellient=disabled \
    -Dplugin_cinterion=disabled \
    -Dplugin_dell=disabled -Dplugin_dlink=disabled -Dplugin_foxconn=disabled -Dplugin_fibocom=disabled \
    -Dplugin_generic=disabled \
    -Dplugin_gosuncn=disabled \
    -Dplugin_haier=disabled -Dplugin_huawei=disabled -Dplugin_intel=disabled -Dplugin_iridium=disabled \
    -Dplugin_linktop=disabled -Dplugin_longcheer=disabled -Dplugin_mbm=disabled -Dplugin_motorola=disabled \
    -Dplugin_mtk=disabled -Dplugin_mtk_legacy=disabled -Dplugin_netprisma=disabled -Dplugin_nokia=disabled \
    -Dplugin_nokia_icera=disabled \
    -Dplugin_novatel=disabled \
    -Dplugin_novatel_lte=disabled -Dplugin_option=disabled -Dplugin_option_hso=disabled -Dplugin_pantech=disabled \
    -Dplugin_qcom_soc=disabled -Dplugin_quectel=disabled -Dplugin_rolling=disabled -Dplugin_samsung=disabled \
    -Dplugin_sierra_legacy=disabled \
    -Dplugin_sierra=disabled -Dplugin_simtech=disabled -Dplugin_telit=disabled -Dplugin_thuraya=disabled \
    -Dplugin_tplink=disabled -Dplugin_ublox=disabled -Dplugin_via=disabled -Dplugin_wavecom=disabled \
    -Dplugin_x22x=disabled -Dplugin_zte=disabled \
"

do_install:append() {
    install -d ${D}${nonarch_base_libdir}/udev/rules.d
    install -m 0644 ${WORKDIR}/78-mm-allowlist-internal-model.rules ${D}/${nonarch_base_libdir}/udev/rules.d
}

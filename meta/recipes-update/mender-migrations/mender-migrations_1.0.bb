FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI = " \
    file://LICENSE;subdir=${BPN}-${PV} \
    file://0.5.0/01_UPF-hardware-config.sh;subdir=${BPN}-${PV} \
    file://0.6.0/01_NetworkManager-profiles-rename.sh;subdir=${BPN}-${PV} \
    file://0.6.1/01_UPF-rename-from-wpf.sh;subdir=${BPN}-${PV} \
    file://1.0.0/01_Manager-config.sh;subdir=${BPN}-${PV} \
    file://1.0.0/02_BasicStation-config.sh;subdir=${BPN}-${PV} \
    file://1.0.1/01_Manager-config-rights-fix.sh;subdir=${BPN}-${PV} \
    file://1.1.1/01_GPS-disable-if-no-coords.sh;subdir=${BPN}-${PV} \
    file://1.2.0/01_UPF-channel-link.sh;subdir=${BPN}-${PV} \
    file://1.4.0/01_CSGB-config.sh;subdir=${BPN}-${PV} \
    file://1.4.0/02_Set-region.sh;subdir=${BPN}-${PV} \
    file://1.4.1/01_fix-manager-config-permissions.sh;subdir=${BPN}-${PV} \
    file://1.6.0/01_concentratord-location.sh;subdir=${BPN}-${PV} \
    file://1.6.0/02_iptables-add-eth-usb.sh;subdir=${BPN}-${PV} \
    file://1.6.4/01_Concentratord-Model-9XX.sh;subdir=${BPN}-${PV} \
    file://1.6.5/01_BasicStation-Config-Lora-frontend-rev.sh;subdir=${BPN}-${PV} \
    file://1.6.5/02_Concentratord-Config-Lora-frontend-rev.sh;subdir=${BPN}-${PV} \
    file://1.7.0/01_UPF-LoraRegion.sh;subdir=${BPN}-${PV} \
    file://1.7.0/02_BasicStation-LoraRegion.sh;subdir=${BPN}-${PV} \
    file://1.7.0/03_CSCD-LoraRegion.sh;subdir=${BPN}-${PV} \
    file://1.7.0/05_Fix-overlay-directories.sh;subdir=${BPN}-${PV} \
    file://1.7.1/01_VPN-autoconnect.sh;subdir=${BPN}-${PV} \
    file://1.7.1/02_wwan_auto-connect.sh;subdir=${BPN}-${PV} \
    file://1.8.0/01_concentratord-legacy.sh;subdir=${BPN}-${PV} \
    file://1.8.0/02_chrony_sources.sh;subdir=${BPN}-${PV} \
    file://1.8.0/03_iptables-nftables.sh;subdir=${BPN}-${PV} \
    file://1.8.0/04_frequency-plan.sh;subdir=${BPN}-${PV} \
    file://1.8.0/05_openrc-confdir.sh;subdir=${BPN}-${PV} \
    file://1.8.0/06_mender-service-name.sh;subdir=${BPN}-${PV} \
    file://1.8.0/07_opkg-status-loc.sh;subdir=${BPN}-${PV} \
"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=b6142c989ce37a5c76a191352d8bc148"

inherit mender-state-scripts

ALLOW_EMPTY:${PN} = "1"

RDEPENDS:${PN} += "machine-info busybox sed"

# 1.6.0/01_concentratord-location.sh
RDEPENDS:${PN} += "grep"

do_compile() {

    ### Pre-migrations ##
    STAGE=ArtifactInstall_Enter
    TARGET=${MENDER_STATE_SCRIPTS_DIR}/${STAGE}_40

    # These migration are applied *before* the generic migration (file copy) of the /etc folder
    # These migrations should generally create new files in $D_ETC, depending on environement and/or $S_ETC
    # Generic migration does not override existing files of $D_ETC



    ### Post-migrations ###
    STAGE=ArtifactInstall_Enter
    TARGET=${MENDER_STATE_SCRIPTS_DIR}/${STAGE}_60

    # These migration are applied *after* the generic migration (file copy) of the /etc folder
    # These migrations should generally modify existing files of $D_ETC
    cp 0.5.0/01_UPF-hardware-config.sh ${TARGET}_Migration_0.5.0_01_UPF-hardware-config

    cp 0.6.0/01_NetworkManager-profiles-rename.sh ${TARGET}_Migration_0.6.0_01_NetworkManager-profiles-rename
    cp 0.6.1/01_UPF-rename-from-wpf.sh ${TARGET}_Migration_0.6.1_01_UPF-rename-from-wpf

    cp 1.0.0/01_Manager-config.sh ${TARGET}_Migration_1.0.0_01_Manager-config
    cp 1.0.0/02_BasicStation-config.sh ${TARGET}_Migration_1.0.0_02_BasicStation-config

    cp 1.0.1/01_Manager-config-rights-fix.sh ${TARGET}_Migration_1.0.1_01_Manager-config-rights-fix

    cp 1.1.1/01_GPS-disable-if-no-coords.sh ${TARGET}_Migration_1.1.1_01_GPS-disable-if-no-coords

    cp 1.2.0/01_UPF-channel-link.sh ${TARGET}_Migration_1.2.0_01_UPF-channel-link

    cp 1.4.0/01_CSGB-config.sh ${TARGET}_Migration_1.4.0_01_CSGB-config
    cp 1.4.0/02_Set-region.sh ${TARGET}_Migration_1.4.0_02_Set-region

    cp 1.4.1/01_fix-manager-config-permissions.sh ${TARGET}_Migration_1.4.1_01_fix-manager-config-permissions

    cp 1.6.0/01_concentratord-location.sh ${TARGET}_Migration_1.6.0_01_concentratord-location
    cp 1.6.0/02_iptables-add-eth-usb.sh ${TARGET}_Migration_1.6.0_02_iptables-add-eth-usb
    
    cp 1.6.4/01_Concentratord-Model-9XX.sh ${TARGET}_Migration_1.6.4_01_Concentratord-Model-9XX

    cp 1.6.5/01_BasicStation-Config-Lora-frontend-rev.sh ${TARGET}_Migration_1.6.5_01_BasicStation-Config-Lora-frontend-rev
    cp 1.6.5/02_Concentratord-Config-Lora-frontend-rev.sh ${TARGET}_Migration_1.6.5_02_Concentratord-Config-Lora-frontend-rev

    cp 1.7.0/01_UPF-LoraRegion.sh ${TARGET}_Migration_1.7.0_01_UPF-LoraRegion
    cp 1.7.0/02_BasicStation-LoraRegion.sh  ${TARGET}_Migration_1.7.0_02_BasicStation-LoraRegion
    cp 1.7.0/03_CSCD-LoraRegion.sh  ${TARGET}_Migration_1.7.0_03_CSCD-LoraRegion
    cp 1.7.0/05_Fix-overlay-directories.sh  ${TARGET}_Migration_1.7.0_05_Fix-overlay-directories

    cp 1.7.1/01_VPN-autoconnect.sh ${TARGET}_Migration_1.7.1_01_VPN-autoconnect
    cp 1.7.1/02_wwan_auto-connect.sh ${TARGET}_Migration_1.7.1_02_wwan_auto-connect

    cp 1.8.0/01_concentratord-legacy.sh ${TARGET}_Migration_1.8.0_01_concentratord-legacy
    cp 1.8.0/02_chrony_sources.sh ${TARGET}_Migration_1.8.0_02_chrony_sources
    cp 1.8.0/03_iptables-nftables.sh ${TARGET}_Migration_1.8.0_03_iptables-nftables
    cp 1.8.0/04_frequency-plan.sh ${TARGET}_Migration_1.8.0_04_frequency-plan
    cp 1.8.0/05_openrc-confdir.sh ${TARGET}_Migration_1.8.0_05_openrc-confdir
    cp 1.8.0/06_mender-service-name.sh ${TARGET}_Migration_1.8.0_06_mender-service-name
    cp 1.8.0/07_opkg-status-loc.sh ${TARGET}_Migration_1.8.0_07_opkg-status-loc
}

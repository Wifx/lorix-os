FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI = " \
    file://LICENSE;subdir=${BPN}-${PV} \
    file://0.5.0/01_UPF-hardware-config.sh;subdir=${BPN}-${PV} \
    file://0.6.0/01_NetworkManager-profiles-rename.sh;subdir=${BPN}-${PV} \
    file://0.6.1/01_UPF-rename-from-wpf.sh;subdir=${BPN}-${PV} \
    file://1.0.0/01_Manager-config.sh;subdir=${BPN}-${PV} \
    file://1.0.0/02_BasicStation-config.sh;subdir=${BPN}-${PV} \
    file://1.0.1/01_Manager-config-rights-fix.sh;subdir=${BPN}-${PV} \
    file://1.1.1/01_GPS-disable-if-no-coords.sh;subdir=${BPN}-${PV} \
"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=8e55ec883d6ec0b7e92fc81cd5069e9a"

inherit mender-state-scripts

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
}

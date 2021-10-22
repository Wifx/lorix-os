FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI = " \
    file://LICENSE;subdir=${BPN}-${PV} \
    file://setup-env.sh;subdir=${BPN}-${PV} \
    file://setup-utils.sh;subdir=${BPN}-${PV} \
    file://check-version.sh;subdir=${BPN}-${PV} \
    file://check-space.sh;subdir=${BPN}-${PV} \
    file://setup-migration.sh;subdir=${BPN}-${PV} \
    file://migrate.sh;subdir=${BPN}-${PV} \
    file://migrate-cleanup.sh;subdir=${BPN}-${PV} \
    file://migrate-reset-immutables.sh;subdir=${BPN}-${PV} \
    file://setup-migration-cleanup.sh;subdir=${BPN}-${PV} \
    file://logs-save.sh;subdir=${BPN}-${PV} \
    file://logs-restore.sh;subdir=${BPN}-${PV} \
    file://config-migration-disable.sh;subdir=${BPN}-${PV} \
    file://config-migration-enable.sh;subdir=${BPN}-${PV} \
    file://version-compare.run;subdir=${BPN}-${PV} \
    file://update-ca-certificates.sh;subdir=${BPN}-${PV} \
"

RDEPENDS_${PN} += "ca-certificates"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=8e55ec883d6ec0b7e92fc81cd5069e9a"

inherit mender-state-scripts

ALLOW_EMPTY_${PN} = "1"

DISTRO_METADATA = " \
    DISTRO='${DISTRO}' \n \
    OS_DISTRO_VERSION='${OS_DISTRO_VERSION}' \n \
    OS_DISTRO_UPGRADE_COMPATIBLE_VERSIONS='${OS_DISTRO_UPGRADE_COMPATIBLE_VERSIONS}' \
"

do_compile() {
    # Download enter

    # Download leave

    # Artifact install enter
    STAGE=ArtifactInstall_Enter

    ## 00 Init
    TARGET=${MENDER_STATE_SCRIPTS_DIR}/${STAGE}_0
    cp version-compare.run ${TARGET}0_Install-version-compare
    cp setup-env.sh ${TARGET}1_Setup-env
    sed -i "s/#distro_metadata#/${DISTRO_METADATA}/" "${TARGET}1_Setup-env"

    cp setup-utils.sh ${TARGET}2_Setup-utils

    ## 10 Checks
    TARGET=${MENDER_STATE_SCRIPTS_DIR}/${STAGE}_1
    cp check-version.sh ${TARGET}0_Check-version
    cp check-space.sh ${TARGET}1_Check-space

    ## 20 Migrations setup
    TARGET=${MENDER_STATE_SCRIPTS_DIR}/${STAGE}_2
    cp setup-migration.sh ${TARGET}0_Setup-migration

    ## 30 Reserved

    ## 40 Specific pre-migrations

    ## 50 Generic migrations
    TARGET=${MENDER_STATE_SCRIPTS_DIR}/${STAGE}_5
    cp migrate.sh ${TARGET}0_Migrate

    ## 60 Specific post-migrations

    ## 90 Migration finalize
    TARGET=${MENDER_STATE_SCRIPTS_DIR}/${STAGE}_9
    cp migrate-reset-immutables.sh ${TARGET}8_Migrate-reset-immutables

    cp setup-migration-cleanup.sh ${TARGET}9_Setup-migration-cleanup

    # Artifact install leave
    STAGE=ArtifactInstall_Leave
    TARGET=${MENDER_STATE_SCRIPTS_DIR}/${STAGE}

    cp config-migration-disable.sh ${TARGET}_90_Config-migration-disable
    cp logs-save.sh ${TARGET}_99_Logs-save


    ### REBOOT ###

    # Artifact commit enter
    STAGE=ArtifactCommit_Enter
    TARGET=${MENDER_STATE_SCRIPTS_DIR}/${STAGE}
    cp logs-restore.sh ${TARGET}_00_Logs-restore

    # Artifact commit leave
    STAGE=ArtifactCommit_Leave
    TARGET=${MENDER_STATE_SCRIPTS_DIR}/${STAGE}
    cp migrate-cleanup.sh ${TARGET}_90_Migrate-cleanup
    cp update-ca-certificates.sh ${TARGET}_90_Update-ca-certificates

    # Artifact rollback enter
    STAGE=ArtifactRollback_Enter
    TARGET=${MENDER_STATE_SCRIPTS_DIR}/${STAGE}
    cp config-migration-enable.sh ${TARGET}_10_Config-migration-enable

    # Artifact rollback leave
    STAGE=ArtifactRollback_Leave
    TARGET=${MENDER_STATE_SCRIPTS_DIR}/${STAGE}

    # Artifact failure enter
    STAGE=ArtifactFailure_Enter
    TARGET=${MENDER_STATE_SCRIPTS_DIR}/${STAGE}
    cp config-migration-enable.sh ${TARGET}_10_Config-migration-enable

    # Artifact failure leave
    STAGE=ArtifactFailure_Leave
    TARGET=${MENDER_STATE_SCRIPTS_DIR}/${STAGE}
    cp setup-migration-cleanup.sh ${TARGET}_00_Setup-migration-cleanup
}

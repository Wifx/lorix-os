FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI = " \
    file://LICENSE;subdir=${BPN}-${PV} \
    file://101_Setup-env.sh;subdir=${BPN}-${PV} \
    file://102_Setup-utils.sh;subdir=${BPN}-${PV} \
    file://110_Check-version.sh;subdir=${BPN}-${PV} \
    file://111_Check-space.sh;subdir=${BPN}-${PV} \
    file://120_Setup-migration.sh;subdir=${BPN}-${PV} \
    file://131_Install-bootstrap-artifact.sh;subdir=${BPN}-${PV} \
    file://150_Migrate.sh;subdir=${BPN}-${PV} \
    file://198_Migrate-reset-immutables.sh;subdir=${BPN}-${PV} \
    file://290_Config-migration-disable.sh;subdir=${BPN}-${PV} \
    file://299_Logs-save.sh;subdir=${BPN}-${PV} \
    file://300_Inhibit-reboot-script-standalone.sh;subdir=${BPN}-${PV} \
    file://390_Logs-restore.sh;subdir=${BPN}-${PV} \
    file://391_Update-ca-certificates.sh;subdir=${BPN}-${PV} \
    file://392_Opkg-configure.sh;subdir=${BPN}-${PV} \
    file://490_Migrate-cleanup.sh;subdir=${BPN}-${PV} \
    file://810_Config-migration-restore.sh;subdir=${BPN}-${PV} \
    file://998_Setup-migration-cleanup.sh;subdir=${BPN}-${PV} \
    file://999_Final-cleanup.sh;subdir=${BPN}-${PV} \
"

RDEPENDS:${PN} += "ca-certificates"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=60704a74c6a3bb355a519fd3d3592955"

inherit mender-state-scripts

ALLOW_EMPTY:${PN} = "1"

DISTRO_METADATA = " \
    DISTRO='${DISTRO}' \n \
    OS_DISTRO_VERSION='${OS_DISTRO_VERSION}' \n \
    OS_DISTRO_UPGRADE_COMPATIBLE_VERSIONS='${OS_DISTRO_UPGRADE_COMPATIBLE_VERSIONS}' \
"

include_script() {
    file=$1
    name=$2

    cp $file ${MENDER_STATE_SCRIPTS_DIR}/${name}
}

do_compile() {

    # Artifact install enter

    ## 00 Init
    include_script 101_Setup-env.sh                         ArtifactInstall_Enter_01_Setup-env
    sed -i "s/#distro_metadata#/${DISTRO_METADATA}/" "${MENDER_STATE_SCRIPTS_DIR}/ArtifactInstall_Enter_01_Setup-env"

    include_script 102_Setup-utils.sh                       ArtifactInstall_Enter_02_Setup-utils

    ## 10 Checks
    include_script 110_Check-version.sh                     ArtifactInstall_Enter_10_Check-version
    include_script 111_Check-space.sh                       ArtifactInstall_Enter_11_Check-space

    ## 20 Migrations setup
    include_script 120_Setup-migration.sh                   ArtifactInstall_Enter_20_Setup-migration

    ## 30 Bootstrap artifact install
    # File ArtifactInstall_Enter_30_bootstrap.mender.run is installed by mender-artifactimg class
    include_script 131_Install-bootstrap-artifact.sh        ArtifactInstall_Enter_31_install-bootstrap-artifact

    ## 40 Specific pre-migrations

    ## 50 Generic migrations
    include_script 150_Migrate.sh                           ArtifactInstall_Enter_50_Migrate

    ## 60 Specific post-migrations

    ## 90 Migration finalize
    include_script 198_Migrate-reset-immutables.sh          ArtifactInstall_Enter_98_Migrate-reset-immutables

    include_script 998_Setup-migration-cleanup.sh           ArtifactInstall_Enter_98_Setup-migration-cleanup
    #include_script 999_Final-cleanup.sh                     ArtifactInstall_Enter_99_Final-cleanup

    # Artifact install leave
    include_script 290_Config-migration-disable.sh          ArtifactInstall_Leave_90_Config-migration-disable
    include_script 299_Logs-save.sh                         ArtifactInstall_Leave_99_Logs-save

    # Artifact reboot enter (this is only executed on managed update)
    include_script 300_Inhibit-reboot-script-standalone.sh  ArtifactReboot_Enter_00_Inhibit-reboot-script-standalone

    ### REBOOT ###

    # Artifact reboot leave (executed either by mender client or init script)
    include_script 390_Logs-restore.sh                      ArtifactReboot_Leave_00_Logs-restore
    include_script 391_Update-ca-certificates.sh            ArtifactReboot_Leave_01_Update-ca-certificates
    include_script 392_Opkg-configure.sh                    ArtifactReboot_Leave_02_OPKG-configure

    # Artifact commit enter

    # Artifact commit leave
    include_script 490_Migrate-cleanup.sh                   ArtifactCommit_Leave_90_Migrate-cleanup

    # Artifact rollback enter
    include_script 810_Config-migration-restore.sh          ArtifactRollback_Enter_10_Config-migration-enable

    # Artifact rollback leave

    # Artifact failure enter
    include_script 810_Config-migration-restore.sh          ArtifactFailure_Enter_10_Config-migration-enable

    # Artifact failure leave
    include_script 998_Setup-migration-cleanup.sh           ArtifactFailure_Leave_00_Setup-migration-cleanup
    include_script 999_Final-cleanup.sh                    ArtifactFailure_Leave_01_Final-cleanup
}

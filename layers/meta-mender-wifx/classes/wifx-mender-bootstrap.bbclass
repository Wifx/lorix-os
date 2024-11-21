inherit mender-bootstrap-artifact

MENDER_BOOTSTRAP_DEPLOY_DIR = "${UBIDATA_DEPLOY_DIR}/mender-bootstrap"

fakeroot do_setup_bootstrap_deploy_dir() {
    install -d "${MENDER_BOOTSTRAP_DEPLOY_DIR}"
}

fakeroot do_install_bootstrap_artifact_wifx () {
    if [ -e "${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.bootstrap-artifact" ]; then
        install -d "${MENDER_BOOTSTRAP_DEPLOY_DIR}/A/"
        install -m 0400 "${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.bootstrap-artifact" "${MENDER_BOOTSTRAP_DEPLOY_DIR}/A/bootstrap.mender"
    fi
}

do_mender_bootstrap() {
    do_setup_bootstrap_deploy_dir
    do_install_bootstrap_artifact_wifx
}

IMAGE_TYPEDEP:dataimg:append = " bootstrap-artifact"

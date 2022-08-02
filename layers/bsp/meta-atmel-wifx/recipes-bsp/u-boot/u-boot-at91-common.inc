# Copyright (c) 2022, Wifx Sarl <info@iot.wifx.net>
# All rights reserved.

do_deploy_append() {
    if [ -e "${ENV_FILEPATH}/${MACHINE}.txt" ]; then
        install -Dm 0644 "${ENV_FILEPATH}/${MACHINE}.txt" "${DEPLOYDIR}/u-boot-env-${MACHINE}.txt"
    fi
}

python() {
    if bb.utils.contains('DISTRO_FEATURES', 'mender-uboot', True, False, d):
        bb.build.addtask('do_cancel_kconfig_verif', 'do_configure', 'do_provide_mender_defines', d)
}

do_cancel_kconfig_verif() {
    set -x

    # make mender_Kconfig_fragment file used to verify simply empty
    echo "" > ${S}/mender_Kconfig_fragment
}

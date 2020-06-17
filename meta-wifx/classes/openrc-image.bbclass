# Copyright (c) 2019-2020, Wifx Sàrl <info@wifx.net>
# All rights reserved.

clean_sysvinit_scripts() {
    # remove /etc/init.d directory
    rm -Rf ${IMAGE_ROOTFS}/${sysconfdir}/init.d

    # remove /etc/rc*.d directories
    for level in S 0 1 2 3 4 5 6; do
        rm -Rf ${IMAGE_ROOTFS}/${sysconfdir}/rc$level.d
    done
}
ROOTFS_POSTPROCESS_COMMAND += "${@bb.utils.contains('DISTRO_FEATURES','openrc','clean_sysvinit_scripts;','',d)} "

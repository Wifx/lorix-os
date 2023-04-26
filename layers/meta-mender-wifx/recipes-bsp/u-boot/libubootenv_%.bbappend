# Copyright (c) 2022, Wifx Sarl <info@iot.wifx.net>
# All rights reserved.

FILES:${PN}:remove:mender-uboot = " /data/u-boot/fw_env.config"

do_install:append:mender-uboot() {
    # Delete mender layer installation files
    rm -f ${D}${sysconfdir}/fw_env.config
    rm -rf ${D}/data

    # Install fw_env.config in /etc directly
    install -m 0644 ${WORKDIR}/fw_env.config ${D}${sysconfdir}/fw_env.config
}

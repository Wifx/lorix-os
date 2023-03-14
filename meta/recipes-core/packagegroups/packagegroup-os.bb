# Copyright (c) 2019-2020, Wifx Sàrl <info@wifx.net>
# All rights reserved.

SUMMARY = "OS package group"
LICENSE = "Apache-2.0"

PR = "r0"

inherit packagegroup

RDEPENDS_${PN} = " \
    packagegroup-os-boot \
    packagegroup-os-base \
    packagegroup-os-machine \
    packagegroup-os-full-cmdline \
    packagegroup-os-connectivity \
    packagegroup-os-extended \
    ${@bb.utils.contains('MACHINE_FEATURES', 'lora', 'packagegroup-os-lora', '', d)} \
    libgpiod \
    os-release \
    chrony \
    chronyc \
    opkg \
    distro-feed-configs \
    run-postinsts \
    ${@bb.utils.contains('DISTRO_FEATURES', 'openrc', 'openrc', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'openrc', 'openrc-base-files', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'manager', 'manager manager-gui', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pmonitor', 'pmonitor pmcli', '', d)} \
    virtual/updater \
"

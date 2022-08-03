# Copyright (c) 2019-2020, Wifx Sàrl <info@wifx.net>
# All rights reserved.
#  Heavilly based on the standard Poky packagegroup-core-boot.bb recipe
#  Copyright (C) 2007 OpenedHand Ltd.
#
SUMMARY = "Minimal OS boot requirements"
DESCRIPTION = "The minimal set of packages required to boot the system"
PR = "r0"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

#
# Set by the machine configuration with packages essential for device bootup
#
MACHINE_ESSENTIAL_EXTRA_RDEPENDS ?= ""
MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS ?= ""

# Distro can override the following VIRTUAL-RUNTIME providers:
VIRTUAL-RUNTIME_dev_manager ?= "udev"
VIRTUAL-RUNTIME_login_manager ?= "busybox"
VIRTUAL-RUNTIME_init_manager ?= "sysvinit"
VIRTUAL-RUNTIME_initscripts ?= "initscripts"
VIRTUAL-RUNTIME_keymaps ?= "keymaps"
VIRTUAL-RUNTIME_watchdog ?= "watchdog"
VIRTUAL-RUNTIME_syslog ?= "busybox-syslog"

EFI_PROVIDER ??= "grub-efi"

SYSVINIT_SCRIPTS = "${@bb.utils.contains('MACHINE_FEATURES', 'rtc', '${VIRTUAL-RUNTIME_base-utils-hwclock}', '', d)} \
                    modutils-initscripts \
                    init-ifupdown \
                    ${VIRTUAL-RUNTIME_initscripts} \
                   "

RDEPENDS_${PN} = "\
    base-files \
    base-passwd \
    base-files-os \
    base-files-machine \
    ${VIRTUAL-RUNTIME_base-utils} \
    ${VIRTUAL-RUNTIME_watchdog} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'sysvinit', '${SYSVINIT_SCRIPTS}', '', d)} \
    ${@bb.utils.contains('MACHINE_FEATURES', 'efi', '${EFI_PROVIDER} kernel', '', d)} \
    netbase \
    ${VIRTUAL-RUNTIME_login_manager} \
    ${VIRTUAL-RUNTIME_init_manager} \
    ${VIRTUAL-RUNTIME_dev_manager} \
    ${VIRTUAL-RUNTIME_update-alternatives} \
    ${MACHINE_ESSENTIAL_EXTRA_RDEPENDS}"

RRECOMMENDS_${PN} = "\
    ${MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS}"

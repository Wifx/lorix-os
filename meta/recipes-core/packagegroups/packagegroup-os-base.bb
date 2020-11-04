# Copyright (c) 2019-2020, Wifx Sàrl <info@wifx.net>
# All rights reserved.
#  Heavilly based on the standard Poky packagegroup-base.bb recipe
#
SUMMARY = "OS base package group"
LICENSE = "Apache-2.0"

PR = "r0"

#
# packages which content depend on MACHINE_FEATURES need to be MACHINE_ARCH
#
PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PROVIDES = "${PACKAGES}"
PACKAGES = " \
    packagegroup-os-base \
    \
    ${@bb.utils.contains('MACHINE_FEATURES', 'usbgadget', 'packagegroup-os-base-usbgadget', '', d)} \
    ${@bb.utils.contains('MACHINE_FEATURES', 'usbhost', 'packagegroup-os-base-usbhost', '', d)} \
    \
    ${@bb.utils.contains('DISTRO_FEATURES', 'ipsec', 'packagegroup-os-base-ipsec', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'ipv6', 'packagegroup-os-base-ipv6', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'nfs', 'packagegroup-os-base-nfs', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'ppp', 'packagegroup-os-base-ppp', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'zeroconf', 'packagegroup-os-base-zeroconf', '', d)} \
"

SUMMARY = "${DISTRO} extras"
DEPENDS = "${DISTRO_EXTRA_DEPENDS}"

#
# packagegroup-os-base contain stuff needed for base system (machine related)
#
# Do not include packagegroup-core-boot, already managed by packagegroup-os-boot
DISTRO_EXTRA_RDEPENDS_remove = " \
    packagegroup-core-boot \
"
RDEPENDS_packagegroup-os-base = "\
    ${DISTRO_EXTRA_RDEPENDS} \
    ${@bb.utils.contains('COMBINED_FEATURES', 'usbgadget', 'packagegroup-os-base-usbgadget', '',d)} \
    ${@bb.utils.contains('COMBINED_FEATURES', 'usbhost', 'packagegroup-os-base-usbhost', '',d)} \
    \
    ${@bb.utils.contains('DISTRO_FEATURES', 'nfs', 'packagegroup-os-base-nfs', '',d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'ipv6', 'packagegroup-os-base-ipv6', '',d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'ipsec', 'packagegroup-os-base-ipsec', '',d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'ppp', 'packagegroup-os-base-ppp', '',d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'zeroconf', 'packagegroup-os-base-zeroconf', '',d)} \
"

RRECOMMENDS_packagegroup-os-base = "\
    ${DISTRO_EXTRA_RRECOMMENDS} \
    kernel-module-nls-utf8 \
    kernel-module-input \
    kernel-module-uinput \
    kernel-module-rtc-dev \
    kernel-module-rtc-proc \
    kernel-module-rtc-sysfs \
    kernel-module-unix"

SUMMARY_packagegroup-os-base-usbgadget = "USB gadget support"
RRECOMMENDS_packagegroup-os-base-usbgadget = "\
    kernel-module-gadgetfs \
    kernel-module-g-serial"

SUMMARY_packagegroup-os-base-usbhost = "USB host support"
RDEPENDS_packagegroup-os-base-usbhost = "\
    usbutils"
RRECOMMENDS_packagegroup-os-base-usbhost = "\
    kernel-module-uhci-hcd \
    kernel-module-ohci-hcd \
    kernel-module-ehci-hcd \
    kernel-module-usbcore \
    kernel-module-sd-mod \
    kernel-module-usbserial \
    kernel-module-usb-storage"

SUMMARY_packagegroup-os-base-ipv6 = "IPv6 support"
RDEPENDS_packagegroup-os-base-ipv6 = ""
RRECOMMENDS_packagegroup-os-base-ipv6 = "\
    kernel-module-ipv6"

SUMMARY_packagegroup-os-base-ppp = "PPP dial-up protocol support"
RDEPENDS_packagegroup-os-base-ppp = "\
    ppp \
    ppp-dialin"
RRECOMMENDS_packagegroup-os-base-ppp = "\
    kernel-module-ppp-async \
    kernel-module-ppp-deflate \
    kernel-module-ppp-generic \
    kernel-module-ppp-mppe \
    kernel-module-slhc"

SUMMARY_packagegroup-os-base-ipsec = "IPSEC support"
RDEPENDS_packagegroup-os-base-ipsec = ""
RRECOMMENDS_packagegroup-os-base-ipsec = "\
    kernel-module-ipsec"

#
# packagegroup-os-base-nfs provides ONLY client support - server is in nfs-utils package
#
SUMMARY_packagegroup-os-base-nfs = "NFS network filesystem support"
RDEPENDS_packagegroup-os-base-nfs = "\
    rpcbind"
RRECOMMENDS_packagegroup-os-base-nfs = "\
    kernel-module-nfs"

SUMMARY_packagegroup-os-base-zeroconf = "Zeroconf support"
RDEPENDS_packagegroup-os-base-zeroconf = "\
    avahi-daemon"
RDEPENDS_packagegroup-os-base-zeroconf_append_libc-glibc = "\
    libnss-mdns"

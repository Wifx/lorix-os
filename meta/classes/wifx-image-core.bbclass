# Copyright (c) 2019-2020, Wifx Sàrl <info@wifx.net>
# All rights reserved.

# Inherit from core-image to support features like debug-tweaks or package-management
inherit core-image
inherit openrc-image

IMAGE_FEATURES += " package-management"

MENDER_PACKAGES = " \
    mender-migrations \    
    mender-state-scripts-base \
    mender-standalone-scripts \
"

# Don't use default CORE_IMAGE_BASE_INSTALL in IMAGE_INSTALL
IMAGE_INSTALL = " \
    packagegroup-os \
    ${@bb.utils.contains('DISTRO_FEATURES', 'mender', '${MENDER_PACKAGES}', '', d)} \
    ${CORE_IMAGE_EXTRA_INSTALL} \
    usb-gadget \
"

BAD_RECOMMENDATIONS:append = " \
    shared-mime-info \
    cryptodev-module \
    valgrind \
    zabbix \
    helium-gateway \
"

PACKAGE_EXCLUDE:append = " \
    udev-hwdb \
"

# Cleanup unwanted services
# - agetty: duplicates getty
# - netmount: not used, network is managed by NetworkManager
# - networkmanager: duplicates NetworkManager init script
OPENRC_DELETED_SERVICES += " \
    agetty \
    netmount \
    networkmanager \
"

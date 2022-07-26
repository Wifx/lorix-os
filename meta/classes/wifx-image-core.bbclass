# Copyright (c) 2019-2020, Wifx Sàrl <info@wifx.net>
# All rights reserved.

# Inherit from core-image to support features like debug-tweaks or package-management
inherit core-image
inherit openrc-image

IMAGE_FEATURES += " package-management"

# Don't use default CORE_IMAGE_BASE_INSTALL for IMAGE_INSTALL
IMAGE_INSTALL = " \
    packagegroup-os \
    ${@bb.utils.contains('DISTRO_FEATURES', 'mender', 'mender-migrations', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'mender', 'mender-state-scripts-base', '', d)} \
    ${CORE_IMAGE_EXTRA_INSTALL} \
"

PACKAGE_EXCLUDE += " \
    udev-hwdb \
"

BAD_RECOMMENDATIONS += " \
    shared-mime-info \
    cryptodev-module \
"

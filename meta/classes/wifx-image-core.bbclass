# Copyright (c) 2019-2020, Wifx Sàrl <info@wifx.net>
# All rights reserved.

# Inherit from core-image to support features like debug-tweaks or package-management
inherit core-image
inherit openrc-image

IMAGE_FEATURES += " package-management"

# Don't use default CORE_IMAGE_BASE_INSTALL for IMAGE_INSTALL
IMAGE_INSTALL = " \
    ${CORE_IMAGE_EXTRA_INSTALL} \
    packagegroup-os \
"

PACKAGE_EXCLUDE += " \
    udev-hwdb \
"

BAD_RECOMMENDATIONS = " \
    shared-mime-info \
    cryptodev-module \
"

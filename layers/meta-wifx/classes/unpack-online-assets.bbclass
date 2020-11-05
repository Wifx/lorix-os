# Copyright (c) 2019-2020, Wifx Sàrl <info@wifx.net>
# All rights reserved.

ASSETS_ARCHIVE_NAME = "${PN}-${PV}-${PR}-${TUNE_PKGARCH}.tar.bz2"

ONLINE_PACKAGES_ASSETS_PATH ?= "https://download.wifx.net/yocto/sources/lorix-os/packages-assets"

ONLINE_ASSETS_ARCHIVE_PATH = "${ONLINE_PACKAGES_ASSETS_PATH}/${PN}/${ASSETS_ARCHIVE_NAME}"

python __anonymous() {
    if not bb.utils.to_boolean(d.getVar('INHIBIT_UNPACK_ONLINE_ASSETS', True)):
        d.appendVar('SRC_URI', ' ' + d.getVar('ONLINE_ASSETS_ARCHIVE_PATH'))
        d.appendVar('INSANE_SKIP_' + d.getVar('PN'), ' already-stripped')
}

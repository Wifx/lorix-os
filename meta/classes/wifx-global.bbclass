# Copyright (c) 2022, Wifx Sarl <info@iot.wifx.net>
# All rights reserved.

inherit wifx-setup
inherit wifx-tools
inherit wifx-machine
inherit wifx-mender

WORKSPACE_REV_HASH := "${@get_os_rev(True, d)}"
WORKSPACE_REV_DATE := "${@get_os_rev_date(d)}"
RELEASE_ARTIFACT_NAME := "${DISTRO}-${DISTRO_VERSION}+${WORKSPACE_REV_HASH}"

inherit wifx-setup
inherit wifx-tools
inherit wifx-machine
inherit mender-full-ubi mender-standalone

WORKSPACE_REV_HASH := "${@get_rel_path_rev('meta', '../', True, d)}"
WORKSPACE_REV_DATE := "${@get_rel_path_rev_date('meta', '../', d)}"
RELEASE_ARTIFACT_NAME := "${DISTRO}-${DISTRO_VERSION}+${WORKSPACE_REV_HASH}"

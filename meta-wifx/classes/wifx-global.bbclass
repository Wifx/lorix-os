inherit wifx-tools

WORKSPACE_REV_HASH := "${@get_rel_path_rev('meta-wifx', '../', True, d)}"
WORKSPACE_REV_DATE := "${@get_rel_path_rev_date('meta-wifx', '../', d)}"
RELEASE_ARTIFACT_NAME := "${DISTRO}-${DISTRO_VERSION}+${WORKSPACE_REV_HASH}"
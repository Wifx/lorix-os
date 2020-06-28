inherit wifx-tools

#WORKSPACE_REV_HASH := "${@get_rel_path_rev('meta-wifx', '../', True, d)}"
#WORKSPACE_REV_DATE := "${@get_rel_path_rev_date('meta-wifx', '../', d)}"
WORKSPACE_REV_HASH := "012345a"
WORKSPACE_REV_DATE := "2020-06-28T08:55:00Z"
RELEASE_ARTIFACT_NAME := "${DISTRO}-${DISTRO_VERSION}+${WORKSPACE_REV_HASH}"
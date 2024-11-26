#!/bin/sh

PREFIX=CHECK-VERSION

source /data/mender/upgrade/migration-env.sh
source /data/mender/upgrade/semver

log $PREFIX "Actual release"
log $PREFIX "- Distro: ${ORIGIN_DISTRO}"
log $PREFIX "- OS version: ${ORIGIN_VERSION}"

log $PREFIX "Upgrade artifact"
log $PREFIX "- Distro: ${TARGET_DISTRO}"
log $PREFIX "- OS version: ${TARGET_VERSION}"
log $PREFIX "- Upgradable OS versions: ${TARGET_COMPATIBLE_VERSIONS}"

# Remove anything after the first + from TARGET_VERSION as version-compare does not support it and it's not used in the comparison
TARGET_VERSION=$(echo $TARGET_VERSION | cut -d'+' -f1)

VALID=$(semver_match_constraints "${ORIGIN_VERSION}" "${TARGET_COMPATIBLE_VERSIONS}")

if [ "${VALID}" = "1" ]; then
    log $PREFIX "The upgrade from '${ORIGIN_VERSION}' to '${TARGET_VERSION}' is supported"
    exit 0
elif [ "${VALID}" = "0" ]; then
    log $PREFIX "The upgrade from '${ORIGIN_VERSION}' to '${TARGET_VERSION}' is not supported"
    exit 1
fi

log $PREFIX "Upgrade check not supported, skipping"
exit 0

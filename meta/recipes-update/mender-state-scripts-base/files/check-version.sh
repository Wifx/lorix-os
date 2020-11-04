#!/bin/sh

VERSION_COMPARE_PATH=/data/mender/version-compare
PREFIX=CHECK-VERSION

source /data/mender/migration-env

log $PREFIX "Actual release"
log $PREFIX "- Distro: ${ORIGIN_DISTRO}"
log $PREFIX "- OS version: ${ORIGIN_VERSION}"

log $PREFIX "Upgrade artifact"
log $PREFIX "- Distro: ${TARGET_DISTRO}"
log $PREFIX "- OS version: ${TARGET_VERSION}"
log $PREFIX "- Upgradable OS versions: ${TARGET_COMPATIBLE_VERSIONS}"

VALID=$($VERSION_COMPARE_PATH "${ORIGIN_VERSION}" "${UPDATE_COMPATIBLE_VERSIONS}")

RESULT=$?

if [ $RESULT -eq 0 ]; then
    if [ "${VALID}" = true ]; then
        log $PREFIX "The upgrade from '${ORIGIN_VERSION}' to '${TARGET_VERSION}' is supported"
        exit 0
    elif [ "${VALID}" = false ]; then
        log $PREFIX "The upgrade from '${ORIGIN_VERSION}' to '${TARGET_VERSION}' is not supported"
        exit 1
    fi
fi

log $PREFIX "Upgrade check not supported, skipping"
exit 0

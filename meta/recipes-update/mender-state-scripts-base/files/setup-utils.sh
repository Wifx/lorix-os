#!/bin/sh

MENDER_DIR=/data/mender
ENV_FILE_PATH=$MENDER_DIR/migration-utils

echo '#!/bin/sh

VERSION_COMPARE_PATH=/data/mender/version-compare

if [[ -z "$MIGRATION_CONDITION" ]]; then
    if [[ ! -z "$VERSION_MAX" ]]; then
        MIGRATION_CONDITION="<$VERSION_MAX"
    fi

    if [[ ! -z "$VERSION_MIN" ]]; then
        MIGRATION_CONDITION+=" >=$VERSION_MIN"
    fi
fi

if [[ ! -z "$MIGRATION_CONDITION" ]]; then
    log "$PREFIX" "Checking if origin release (${ORIGIN_VERSION}) is in range for migration ($MIGRATION_CONDITION)"

    VALID=$($VERSION_COMPARE_PATH "${ORIGIN_VERSION}" "$MIGRATION_CONDITION")
    RESULT=$?

    if [ $RESULT -eq 0 ]; then
        if [ "${VALID}" = true ]; then
            log "$PREFIX" "Origin release (${ORIGIN_VERSION}) is in range ($MIGRATION_CONDITION)"
        else
            log "$PREFIX" "Migration not applied, origin release (${ORIGIN_VERSION}) conditions not met (${MIGRATION_CONDITION})"
            exit 0
        fi
    else
        log "$PREFIX" "Error checking origin release range: $VALID"
    fi
else
    log "$PREFIX" "No migration condition given"
fi

log "$PREFIX" "Applying migration..."

' > $ENV_FILE_PATH
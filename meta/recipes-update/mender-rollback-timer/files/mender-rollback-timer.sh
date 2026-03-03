#!/bin/sh

TIMEOUT=${1}
if [ -z "$TIMEOUT" ]; then
    TIMEOUT=7200
fi

sleep "$TIMEOUT"

# Read U-Boot environment variable to check if an update is still pending.
# Mender sets upgrade_available to 1 and it is cleared when commit is executed.
if [ "$(fw_printenv -n upgrade_available 2>/dev/null)" = "1" ]; then
    logger -t mender-rollback "Mender update wasn't committed within ${TIMEOUT}s. Running \`mender-update rollback\`."
    mender-update rollback
    reboot -f
else
    logger -t mender-rollback "Mender update was committed within ${TIMEOUT}s. No rollback needed."
fi

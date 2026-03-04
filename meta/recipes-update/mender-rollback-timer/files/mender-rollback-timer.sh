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

    # Trigger an OpenRC graceful stop in the background
    if [ -n "$RC_SVCNAME" ] && command -v rc-service >/dev/null 2>&1; then
        ( rc-service "$RC_SVCNAME" stop ) &
        # Block this main process so rc-service can send SIGTERM to kill it cleanly,
        # preventing OpenRC from detecting a premature exit and marking it "crashed".
        while true; do sleep 3600; done
    fi
fi

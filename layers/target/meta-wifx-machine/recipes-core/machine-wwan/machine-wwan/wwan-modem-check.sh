#!/bin/sh

SERVICE="wwan"
DEVICE=$1
INHIBIT_FILE="/run/wwan-modem-check.inhibit"

logger -p daemon.debug -t wwan-modem-check "Device $DEVICE: $ACTION"

if [ "$ACTION" != "remove" ]; then
    exit 0
fi

# Check for inhibit file
if [ -e "$INHIBIT_FILE" ]; then
    logger -p daemon.info -t wwan-modem-check "Inhibit file $INHIBIT_FILE found. Skipping WWAN modem check."
    exit 0
fi

if [ -z "$DEVICE" ]; then
    echo "Usage: $0 <device>"
    exit 1
fi

logger -p daemon.err -t wwan-modem-check "WWAN modem not found at $DEVICE, restarting $SERVICE..."
rc-service "$SERVICE" restart
if [ $? -ne 0 ]; then
    logger -p daemon.err -t wwan-modem-check "Failed to restart $SERVICE"
    exit 1
fi

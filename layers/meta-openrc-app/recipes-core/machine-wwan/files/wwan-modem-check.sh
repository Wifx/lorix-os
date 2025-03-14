#!/bin/sh

DEVICE="/sys/devices/platform/ahb/600000.ehci/usb1/1-2"
SERVICE="wwan"

if [ ! -e "$DEVICE" ]; then
    logger -p daemon.err -t wwan-modem-check "WWAN modem not found at $DEVICE, restarting $SERVICE..."
    rc-service "$SERVICE" restart
fi

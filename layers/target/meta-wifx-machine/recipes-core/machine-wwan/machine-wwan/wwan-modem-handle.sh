#!/bin/bash

# Path to the specific USB device that ModemManager should manage
DEVICE_REL_PATH="/devices/platform/ahb/600000.ehci/usb1/1-2"
DEVICE_FULL_PATH="/sys$DEVICE_REL_PATH"
LOGGER_TAG="wwan-modem-handle"
PRE_SCAN_GRACE_PERIOD=10
POST_SCAN_GRACE_PERIOD=30

is_device_handled() {
    local path

    for path in $(mmcli -J -L 2>/dev/null | jq -r '."modem-list"[]?'); do
        if mmcli -m "$path" 2>/dev/null | grep -Fq "$DEVICE_REL_PATH"; then
            return 0
        fi
    done

    return 1
}

if [ ! -e "$DEVICE_FULL_PATH" ]; then
    exit 0
fi

if is_device_handled; then
    logger -p daemon.debug -t "$LOGGER_TAG" "Device $DEVICE_FULL_PATH is already handled by ModemManager"
    exit 0
fi

logger -p daemon.warn -t "$LOGGER_TAG" "Device $DEVICE_FULL_PATH exists but is not handled by ModemManager, waiting ${PRE_SCAN_GRACE_PERIOD} seconds before rescanning"
sleep "$PRE_SCAN_GRACE_PERIOD"

if is_device_handled; then
    logger -p daemon.info -t "$LOGGER_TAG" "Device $DEVICE_FULL_PATH is handled by ModemManager after the wait"
    exit 0
fi

logger -p daemon.warn -t "$LOGGER_TAG" "Device $DEVICE_FULL_PATH is still not handled by ModemManager, asking for a scan"
if ! mmcli -S >/dev/null 2>&1; then
    logger -p daemon.error -t "$LOGGER_TAG" "Failed to trigger ModemManager scan"
    exit 1
fi
logger -p daemon.info -t "$LOGGER_TAG" "ModemManager scan triggered, waiting ${POST_SCAN_GRACE_PERIOD} seconds before checking ModemManager again"

sleep "$POST_SCAN_GRACE_PERIOD"

if is_device_handled; then
    logger -p daemon.info -t "$LOGGER_TAG" "Device $DEVICE_FULL_PATH is handled by ModemManager after the scan"
    exit 0
fi

logger -p daemon.error -t "$LOGGER_TAG" "Device $DEVICE_FULL_PATH is still not handled after the scan, restarting wwan service"
if ! rc-service wwan restart >/dev/null 2>&1; then
    logger -p daemon.error -t "$LOGGER_TAG" "Failed to restart wwan service"
    exit 1
fi
logger -p daemon.info -t "$LOGGER_TAG" "wwan service restarted"

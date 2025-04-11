#!/bin/bash

PROFILE="wwan"

# Check if wwan profile has autoconnect enabled
AUTOCONNECT=$(nmcli -g connection.autoconnect connection show "$PROFILE")
if [[ $? -ne 0 ]]; then
    logger -p daemon.error -t wwan-autoconnect-unblock "Failed to retrieve autoconnect status for $PROFILE"
    exit 1
fi

if [[ "$AUTOCONNECT" != "yes" ]]; then
    logger -p daemon.debug -t wwan-autoconnect-unblock "Autoconnect is disabled for $PROFILE, exiting"
    exit 0
fi

# Check modem state
MODEM_STATE=$(mmcli -J -m any | jq -r .modem.generic.state)
if [[ $? -ne 0 ]]; then
    logger -p daemon.error -t wwan-autoconnect-unblock "Failed to retrieve modem state"
    exit 1
fi

if [[ "$MODEM_STATE" != "registered" ]]; then
    exit 0
fi

logger -p daemon.debug -t wwan-autoconnect-unblock "Modem is in registered state, waiting for stabilization"

# Wait for 5 seconds to allow the modem to stabilize
sleep 5

# Check if the modem is still in registered state
MODEM_STATE=$(mmcli -J -m any | jq -r .modem.generic.state)
if [[ $? -ne 0 ]]; then
    logger -p daemon.error -t wwan-autoconnect-unblock "Failed to retrieve modem state after waiting"
    exit 1
fi
if [[ "$MODEM_STATE" != "registered" ]]; then
    logger -p daemon.debug -t wwan-autoconnect-unblock "Modem is no longer in registered state, exiting"
    exit 0
fi

logger -p daemon.warn -t wwan-autoconnect-unblock "Modem seems to be stuck in registered state, trying to unblock"

# Unblock the device
if ! nmcli con up "$PROFILE"; then
    logger -p daemon.error -t wwan-autoconnect-unblock "Failed to connect the profile '$PROFILE' using nmcli"
    exit 1
fi

logger -p daemon.info -t wwan-autoconnect-unblock "Profile $PROFILE connected successfully"

#!/bin/bash

# This script is used to reconnect to the VPN when it goes down.
#
# The script reads the configuration files in the VPN_AUTOCONNECT_ENABLED_CONFIG_DIR directory.
# Each file in the directory contains (name of file) the UUID of the VPN connection and the UUIDs of the carrier connections that should trigger the VPN connection.
# The script checks if the connection is in the list of carrier connections and activates the VPN connection if it is not already active.

INTERFACE=$1
STATUS=$2

VPN_AUTOCONNECT_ENABLED_CONFIG_DIR="/etc/NetworkManager/vpn-autoconnect/enabled"

# Check if directory exists
if [ ! -d "$VPN_AUTOCONNECT_ENABLED_CONFIG_DIR" ]; then
  logger -p daemon.debug -t vpn-autoconnect "Auto-connect directory $VPN_AUTOCONNECT_ENABLED_CONFIG_DIR does not exist"
  exit 0
fi

if [ "$STATUS" != "vpn-down" ] && [ "$STATUS" != "force-reconnect" ]; then
  exit 0
fi

# Handle empty directory case
shopt -s nullglob
files=($VPN_AUTOCONNECT_ENABLED_CONFIG_DIR/*)
if [ ${#files[@]} -eq 0 ]; then
  logger -p daemon.debug -t vpn-autoconnect "No VPN configurations found in $VPN_AUTOCONNECT_ENABLED_CONFIG_DIR"
  exit 0
fi

# For each file in the VPN_AUTOCONNECT_ENABLED_CONFIG_DIR
for file in $VPN_AUTOCONNECT_ENABLED_CONFIG_DIR/*; do

  # Read the file and get the connection ID
  VPN_CONNECTION_UUID=$(basename "$file")

  # Get connection name for logging
  VPN_CONNECTION_NAME=$(nmcli -g connection.id connection show "$VPN_CONNECTION_UUID" 2>/dev/null || echo "$VPN_CONNECTION_UUID")

  if nmcli -g GENERAL.STATE connection show "$VPN_CONNECTION_UUID" 2>/dev/null | grep -q "activated"; then
    continue
  fi

  # Check if the event is global or on the VPN connection
  if [ -z "$CONNECTION_UUID" ] || [ "$CONNECTION_UUID" == "$VPN_CONNECTION_UUID" ]; then

    # Read the file and get the carrier connection UUIDs (one per line)
    CARRIER_CONNECTION_UUIDS=($(cat "$file"))

    # For each carrier connection
    for CARRIER_CONNECTION_UUID in "${CARRIER_CONNECTION_UUIDS[@]}"; do

      # Check if the carrier connection is active
      if nmcli -g GENERAL.STATE connection show "$CARRIER_CONNECTION_UUID" 2>/dev/null | grep -q "activated"; then
        CARRIER_NAME=$(nmcli -g connection.id connection show "$CARRIER_CONNECTION_UUID" 2>/dev/null || echo "$CARRIER_CONNECTION_UUID")
        logger -p daemon.info -t vpn-autoconnect "Re-activating VPN '$VPN_CONNECTION_NAME' as carrier connection '$CARRIER_NAME' is still active"
        nmcli connection up "$VPN_CONNECTION_UUID"
        break  # Exit after first successful activation
      fi

    done

  fi

done

exit 0

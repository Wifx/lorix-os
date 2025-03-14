#!/bin/bash

# This script is used to automatically connect to a VPN when a specific carrier connection is active.
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

if [ "$STATUS" != "up" ]; then
  exit 0
fi

# Handle empty directory case
shopt -s nullglob
files=("$VPN_AUTOCONNECT_ENABLED_CONFIG_DIR"/*)
if [ ${#files[@]} -eq 0 ]; then
  logger -p daemon.debug -t vpn-autoconnect "No VPN configurations found in $VPN_AUTOCONNECT_ENABLED_CONFIG_DIR"
  exit 0
fi

# Get the connection name for logging
CONNECTION_NAME=$(nmcli -g connection.id connection show "$CONNECTION_UUID" 2>/dev/null || echo "$CONNECTION_UUID")

# For each file in the VPN_AUTOCONNECT_ENABLED_CONFIG_DIR
for file in $VPN_AUTOCONNECT_ENABLED_CONFIG_DIR/*; do

  # Read the file and get the connection name
  VPN_CONNECTION_UUID=$(basename "$file")

  # Get VPN connection name for logging
  VPN_CONNECTION_NAME=$(nmcli -g connection.id connection show "$VPN_CONNECTION_UUID" 2>/dev/null || echo "$VPN_CONNECTION_UUID")

  # Read the file and get the carrier connection UUIDs (one per line)
  CARRIER_CONNECTION_UUIDS=($(cat "$file"))

  # Check if the carrier connection is in the list
  if printf '%s\n' "${CARRIER_CONNECTION_UUIDS[@]}" | grep -qx "$CONNECTION_UUID"; then
    
    # Check if VPN is already active
    if ! nmcli -g GENERAL.STATE connection show "$VPN_CONNECTION_UUID" 2>/dev/null | grep -q "activated"; then
      logger -p daemon.notice -t vpn-autoconnect "Activating VPN '$VPN_CONNECTION_NAME' due to '$CONNECTION_NAME' connection"
      nmcli connection up "$VPN_CONNECTION_UUID"
    fi

  fi

done

exit 0

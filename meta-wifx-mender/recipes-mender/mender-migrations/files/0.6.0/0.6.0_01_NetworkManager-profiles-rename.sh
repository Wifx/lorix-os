#!/bin/sh

PREFIX=MIGRATION-NM-PROFILES-RENAME
source /data/mender/migration-env

VERSION_MAX="0.6.0"
source /data/mender/migration-utils

NM_PROFILES_PATH=NetworkManager/system-connections
PROFILES_DIR_PATH="$D_ETC/$NM_PROFILES_PATH"
ABSOLUTE_PROFILES_DIR_PATH="/etc/$NM_PROFILES_PATH"

DHCP_DEFAULT=dhcp-default.nmconnection
STATIC_DEFAULT=static-default.nmconnection

BACKHAUL=backhaul.nmconnection
SERVICE=service.nmconnection

if [[ ! -d "$PROFILES_DIR_PATH" ]]; then
    log $PREFIX "Network profiles have not been changed from factory"
    exit 0
fi

cd $PROFILES_DIR_PATH

# TODO check with removed files
if [[ -f "$PROFILES_DIR_PATH/$DHCP_DEFAULT" ]]; then
    sed -i -E "s/id=dhcp-default/id=backhaul/" $DHCP_DEFAULT
    mv $DHCP_DEFAULT $BACKHAUL
    log $PREFIX "Network profile '$DHCP_DEFAULT' migrated to '$BACKHAUL' in '$ABSOLUTE_PROFILES_DIR_PATH'"
else
    log $PREFIX "Network profile '$DHCP_DEFAULT' not found, migration not applied"
fi

if [[ -f "$PROFILES_DIR_PATH/$STATIC_DEFAULT" ]]; then
    sed -i -E "s/id=static-default/id=service/" $STATIC_DEFAULT
    mv $STATIC_DEFAULT $SERVICE
    log $PREFIX "Network profile '$STATIC_DEFAULT' migrated to '$SERVICE' in '$ABSOLUTE_PROFILES_DIR_PATH'"
else
    log $PREFIX "Network profile '$STATIC_DEFAULT' not found, migration not applied"
fi

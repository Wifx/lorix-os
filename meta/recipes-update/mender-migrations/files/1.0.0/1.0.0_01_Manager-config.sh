#!/bin/sh

### CONFIGURE THE MIGRATION ###

# The prefix will be shown in the logs only. Keep it short. E.g. "NM_PROF_MV"
PREFIX=MANAGER-CFG 

# The following versions description uses semver: https://semver.org/
# Condition syntax is defined by semver_rs "Range" object: https://docs.rs/semver_rs/0.1.3/semver_rs/struct.Range.html.

# Defines what is the highest version (excluded) of the source system for the migration to be applied (semver).
# Must not be empty. Can be left undefined.
VERSION_MAX="1.0.0" 

### DO NO CHANGE THE FOLLOWING TWO LINES ###

# Load the work variables (do not change)
# - $S_ETC : current etc diff, readonly (/data/layers/config/rootfs[A|B])
# - $D_ETC : current etc diff, readwrite (/data/layers/config/rootfs[A|B] mounted on /var/lib/manager/migration)
# - $S_ROOT : factory root of the active partition, readonly (/data/layers/factory)
source /data/mender/migration-env 

# Checks wheteher the migration should be applied or not (do not change)
source /data/mender/migration-utils 

### WRITE YOUR MIGRATION FROM HERE ###

# You may generally want to go into /etc of the destination rootfs. 
# /!\ Path to files MUST not contain /etc (would refer to the currently mounted config)
cd $D_ETC

OLD_CFG_PATH="manager/config.yml" # Refers to a file at /etc/manager/config.yml

NEW_CFG_DIR="manager/conf.d"
NEW_CFG_API_SECRET_FILE="00-default/01-api-secret-key.toml"
NEW_CFG_API_SECRET_FILE_PATH="$NEW_CFG_DIR/$NEW_CFG_API_SECRET_FILE"

# It is generally a good thing to check wheter the migration should be applied or not depending on the FS state
if [[ ! -f "$OLD_CFG_PATH" ]]; then
    log $PREFIX "No Manager config to migrate at /etc/$OLD_CFG_PATH"
    exit 0
fi

# The migration steps will depend on the type of migration. Prefer post-migration.
# - Pre-migration : copy files from $S_ETC to $D_ETC, edit them but not rename them
# - Post-migration : add, edit or remove files in $D_ETC

log $PREFIX "Migrating..."

if [[ ! -f "$NEW_CFG_API_SECRET_FILE_PATH" ]]; then
    PATTERN='secretKey: (.*)'

    OLD_CONFIG_CONTENT=`grep secretKey $OLD_CFG_PATH`

    if [[ $OLD_CONFIG_CONTENT =~ $PATTERN ]]; then
        
        log $PREFIX "API secret was found, migrating to new file /etc/$NEW_CFG_API_SECRET_FILE_PATH"

        mkdir -p -m 644 "$NEW_CFG_DIR/00-default"

        echo "### This file is auto-generated during migration ###

# Key used for encryption of the authentication token. All devices with the same secret share access tokens.
[api.authentication]
secretKey = \"${BASH_REMATCH[1]}\"
" > "$NEW_CFG_API_SECRET_FILE_PATH"
    else
        log $PREFIX "Could not find an API secret in /etc/$OLD_CFG_PATH"
    fi
else
    log $PREFIX "API secret file already exists at /etc/$NEW_CFG_API_SECRET_FILE_PATH, not migrating the existing key"
fi


DIFF=`diff -bB -U0 $OLD_CFG_PATH $S_ROOT/etc/manager/config.yml`

TEMPLATE_FILE='[+-]{3} '
TEMPLATE_HEADER='@@ [-+ 0-9]+ @@'
TEAMPLATE_SECRET='secretKey'

CHANGED=false
while IFS= read -r line; do

    if [[ $line =~ $TEMPLATE_FILE ]]; then
        :
    elif [[ $line =~ $TEMPLATE_HEADER ]]; then
        :
    elif [[ $line =~ $TEAMPLATE_SECRET ]]; then
        :
    else
        log $PREFIX "Change detected: '$line'"
        CHANGED=true
    fi
done <<< "$DIFF"

if [ "$CHANGED" == "false" ]; then
    log $PREFIX "Config file did NOT change, removing"
    rm -f "$OLD_CFG_PATH"
else
    log $PREFIX "Config file did change, backuping to ${OLD_CFG_PATH}.old"
    mv -f "$OLD_CFG_PATH" "${OLD_CFG_PATH}.old"
fi

log $PREFIX "Migration done"

exit 0

#!/bin/sh

CURRENT_OS_INFO_PATH=/etc/os-release

MENDER_UPGRADE_DIR=/data/mender/upgrade
ENV_FILE_PATH=$MENDER_UPGRADE_DIR/migration-env.sh

UPGRADE_LOG_DIR=/var/log/upgrade
UPGRADE_LOG_PERSISTENT_DIR=$MENDER_UPGRADE_DIR/logs
LAYERS_DIR_NEW=/var/lib/os/layers
LAYERS_DIR_LEGACY=/data/layers

#distro_metadata#

NOW=$(date +"%Y-%m-%dT%H:%m:%SZ")
UPGRADE_LOG_PATH=$UPGRADE_LOG_DIR/$OS_DISTRO_VERSION-$NOW.log

PREFIX=SETUP-ENV

# log is not yet available; write directly to the upgrade log
_log() {
    now=$(date +"%Y-%m-%dT%H:%m:%SZ")
    msg="$now [$1] $2"
    >&2 echo "$msg"
    echo "$msg" >> "$UPGRADE_LOG_PATH"
}

# Create and cleanup upgrade directory
rm -rf $MENDER_UPGRADE_DIR
mkdir -p $MENDER_UPGRADE_DIR
mkdir -p $UPGRADE_LOG_PERSISTENT_DIR
mkdir -p $UPGRADE_LOG_DIR

_log $PREFIX "Setting up upgrade environment (target: $OS_DISTRO_VERSION)"

source $CURRENT_OS_INFO_PATH

if [[ -z $VERSION_NORM ]]; then
    VERSION_NORM=$VERSION_ID
fi

_log $PREFIX "Origin: $ID $VERSION_NORM"

echo '#!/bin/sh

if [ ! -d '$LAYERS_DIR_NEW' ]; then
    LAYERS_DIR='$LAYERS_DIR_LEGACY'
else
    LAYERS_DIR='$LAYERS_DIR_NEW'/active
fi

MOUNT=$(mount)

PATTERN="ubi0_([01]) on $LAYERS_DIR/factory"

if [[ $MOUNT =~ $PATTERN ]]; then
    PARTITION_MATCH=${BASH_REMATCH[1]}

    if [ "$PARTITION_MATCH" == "0" ]; then
        PARTITION_ACTIVE=A
        PARTITION_INACTIVE=B
    elif [ "$PARTITION_MATCH" == "1" ]; then
        PARTITION_ACTIVE=B
        PARTITION_INACTIVE=A
    fi
fi


if [[ -z "$PARTITION_ACTIVE" || -z "$PARTITION_INACTIVE" ]]; then
    echo "Could not determine active partition"
    exit 1
fi
' > $ENV_FILE_PATH


echo "
MENDER_UPGRADE_DIR=$MENDER_UPGRADE_DIR

UPGRADE_LOG_PATH=$UPGRADE_LOG_PATH
UPGRADE_LOG_PERSISTENT_DIR=$UPGRADE_LOG_PERSISTENT_DIR

ORIGIN_DISTRO='$ID'
ORIGIN_VERSION='$VERSION_NORM'

TARGET_DISTRO='$DISTRO'
TARGET_VERSION='$OS_DISTRO_VERSION'
TARGET_COMPATIBLE_VERSIONS='$OS_DISTRO_UPGRADE_COMPATIBLE_VERSIONS'

if [ -d $LAYERS_DIR_NEW ]; then
    LAYER_FACTORY=$LAYERS_DIR_NEW/active/factory
    LAYER_FACTORY_INACTIVE=$LAYERS_DIR_NEW/inactive/factory
    LAYER_FACTORY_INACTIVE_UBI=ubi0_\$(( 1 - PARTITION_MATCH ))
    LAYER_USER=$LAYERS_DIR_NEW/active/user
    LAYER_USER_CONFIG=$LAYERS_DIR_NEW/active/config
    LAYER_USER_CONFIG_INACTIVE=$LAYERS_DIR_NEW/inactive/config
else
    LAYER_FACTORY=$LAYERS_DIR_LEGACY/factory
    LAYER_FACTORY_INACTIVE=/var/lib/migration/factory-inactive
    LAYER_FACTORY_INACTIVE_UBI=ubi0_\$(( 1 - PARTITION_MATCH ))
    LAYER_USER=$LAYERS_DIR_LEGACY/user
    LAYER_USER_CONFIG=$LAYERS_DIR_LEGACY/config/rootfs\$PARTITION_ACTIVE
    LAYER_USER_CONFIG_INACTIVE=$LAYERS_DIR_LEGACY/config/rootfs\$PARTITION_INACTIVE
fi

LAYER_USER_CONFIG_INACTIVE_RW=/var/lib/migration/config

S_ROOT=\$LAYER_FACTORY
S_ETC=\$LAYER_USER_CONFIG
D_ETC=\$LAYER_USER_CONFIG_INACTIVE_RW

" >> $ENV_FILE_PATH


echo '
function log() {
    mkdir -p "${UPGRADE_LOG_PATH%/*}"
    now=$(date +"%Y-%m-%dT%H:%m:%SZ")
    msg="$now [$1] $2"
    >&2 echo "$msg"
    echo "$msg" >> $UPGRADE_LOG_PATH
}
' >> $ENV_FILE_PATH

cat >> $ENV_FILE_PATH << 'ENDFUNC'

version_gte() {
    [ "$1" = "$2" ] && return 0
    [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" = "$2" ]
}

# Read a machine-info attribute using the correct syntax for the detected MI_VERSION
machine_info_read() {
    [ -z "$MI_VERSION" ] && return 1
    if version_gte "$MI_VERSION" "1.0.0"; then
        machine-info read "$1" 2>/dev/null
    else
        machine-info -f "$1" 2>/dev/null | awk -F= '{print $2}'
    fi
}
ENDFUNC

_log $PREFIX "Environment file written: $ENV_FILE_PATH"

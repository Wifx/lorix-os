#!/bin/sh

CURRENT_OS_INFO_PATH=/etc/os-release

MENDER_DIR=/data/mender
ENV_FILE_PATH=$MENDER_DIR/migration-env

UPGRADE_LOG_DIR=/var/log/upgrade
UPGRADE_LOG_PERSISTENT_DIR=$MENDER_DIR/upgrade-logs
LAYERS_DIR=/data/layers

#distro_metadata#

NOW=$(date +"%Y-%m-%dT%H:%m:%SZ")
UPGRADE_LOG_PATH=$UPGRADE_LOG_DIR/$OS_DISTRO_VERSION-$NOW.log

touch $ENV_FILE_PATH
echo '#!/bin/sh

MOUNT=$(mount)
PATTERN="lowerdir=/etc,upperdir=(rootfs[AB])"

if [[ $MOUNT =~ $PATTERN ]]; then
    ROOTFS_MATCH=${BASH_REMATCH[1]}

    if [ "$ROOTFS_MATCH" == "rootfsA" ]; then
        ROOTFS_ACTIVE=rootfsA
        ROOTFS_INACTIVE=rootfsB
    elif [ "$ROOTFS_MATCH" == "rootfsB" ]; then
        ROOTFS_ACTIVE=rootfsB
        ROOTFS_INACTIVE=rootfsA
    fi
fi

if [[ -z "$ROOTFS_ACTIVE" || -z "$ROOTFS_INACTIVE" ]]; then
    echo "Could not determine active rootfs"
    exit 1
fi
' > $ENV_FILE_PATH

source $CURRENT_OS_INFO_PATH

if [[ -z $VERSION_NORM ]]; then
    VERSION_NORM=$VERSION_ID
fi

echo "

UPGRADE_LOG_PATH=$UPGRADE_LOG_PATH
UPGRADE_LOG_PERSISTENT_DIR=$UPGRADE_LOG_PERSISTENT_DIR

ORIGIN_DISTRO='$ID'
ORIGIN_VERSION='$VERSION_NORM'

TARGET_DISTRO='$DISTRO'
TARGET_VERSION='$OS_DISTRO_VERSION'
TARGET_COMPATIBLE_VERSIONS='$OS_DISTRO_UPGRADE_COMPATIBLE_VERSIONS'

LAYER_FACTORY=$LAYERS_DIR/factory
LAYER_USER=$LAYERS_DIR/user
LAYER_USER_CONFIG=$LAYERS_DIR/config/\$ROOTFS_ACTIVE
LAYER_USER_CONFIG_INACTIVE=$LAYERS_DIR/config/\$ROOTFS_INACTIVE
LAYER_USER_CONFIG_INACTIVE_RW=/var/lib/migration/config

S_ROOT=\$LAYER_FACTORY
S_ETC=\$LAYER_USER_CONFIG
D_ETC=\$LAYER_USER_CONFIG_INACTIVE_RW

" >> $ENV_FILE_PATH

mkdir -p $UPGRADE_LOG_DIR

echo '
function log() {
    mkdir -p "${UPGRADE_LOG_PATH%/*}"
    now=$(date +"%Y-%m-%dT%H:%m:%SZ")
    msg="$now [$1] $2"
    >&2 echo "$msg"
    echo "$msg" >> $UPGRADE_LOG_PATH
}
' >> $ENV_FILE_PATH

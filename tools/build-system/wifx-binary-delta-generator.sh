#!/bin/bash -e
#
# generate-wifx-binary-delta.sh
#
# This script generates a binary delta between two Mender artifacts.
#
# Usage:
#   ./generate-wifx-binary-delta.sh <source-artifact> <target-artifact>
#
# Arguments:
#   <source-artifact>  Path to the source Mender artifact.
#   <target-artifact>  Path to the target Mender artifact.
#
# Environment Variables:
#   - XDELTA_FLAGS  Additional flags to pass to xdelta3.
#       - Source buffer size          -B  Default=67108864(64M)  [16384(16K) - Unlimited]
#       - Input window size           -W  Default=8192    ( 8M)  [16384(16K) - 16777216(16M)]
#       - Instruction buffer size     -I  Default=32768(32KB)    [ min?      - 0 (Unlimited) ]
#       - Compression duplicates size -P  Default=262144(256KB)  P <= W, Must be power of 2
#   - SIGN_KEY_PATH  Path to the signing key to use for signing the delta artifact.
#
# Description:
#   This script takes two Mender artifacts as input and generates a binary delta
#   between them.
#   - The device types of the two artifacts must match. (The script will fail if they do not.)
#   - State scripts (migrations) from the target artifact are automatically included in the delta artifact. 
#
# Exit Codes:
#   1  If the script is called with incorrect arguments or if the artifacts are not found.
#
# Dependencies:
#   This script requires the following tools to be installed:
#   - jq: Command-line JSON processor.
#   - tar: Archiving utility.
#   - xdelta3: Binary delta generator.
#
# Example:
#   ./wifx-binary-delta-generator.sh source.mender target.mender
#
# Author:
#   Wifx SA <info@iot.wifx.net>
#
# License:
#   All rights reserved.
#

SOURCE_ARTIFACT_PATH=$1
TARGET_ARTIFACT_PATH=$2

if [ -z "$SOURCE_ARTIFACT_PATH" ] || [ -z "$TARGET_ARTIFACT_PATH" ]; then
    echo "Usage: $0 <source-artifact> <target-artifact>"
    exit 1
fi

if [ ! -f $SOURCE_ARTIFACT_PATH ]; then
    echo "Source artifact not found"
    exit 1
fi

if [ ! -f $TARGET_ARTIFACT_PATH ]; then
    echo "Target artifact not found"
    exit 1
fi

SOURCE_DIR_NAME=$(basename $SOURCE_ARTIFACT_PATH .mender)
TARGET_DIR_NAME=$(basename $TARGET_ARTIFACT_PATH .mender)

get_device_types() {
    local device_types=$(jq -r '.artifact_depends.device_type[]' $1/header/header-info)
    device_types=($device_types)
    echo "${device_types[@]}"
}

extract_artifact() {
    artifact_path=$1
    directory=$2
    rm -rf $directory && mkdir $directory
    tar -xf $artifact_path -C $directory
    mkdir $directory/header && tar -xf $directory/header.tar.gz -C $directory/header
    mkdir -p $directory/data/0000 && tar -xf $directory/data/0000.tar.gz -C $directory/data/0000
}

# Extract artifacts
extract_artifact $SOURCE_ARTIFACT_PATH $SOURCE_DIR_NAME
extract_artifact $TARGET_ARTIFACT_PATH $TARGET_DIR_NAME

# Find device types for both artifacts
source_device_types=($(get_device_types $SOURCE_DIR_NAME))
target_device_types=($(get_device_types $TARGET_DIR_NAME))

# Check that device types are the same for both artifacts
if [ "${source_device_types[*]}" != "${target_device_types[*]}" ]; then
    echo "Device types do not match"
    exit 1
fi

device_types_args=""
for device_type in "${target_device_types[@]}"; do
    device_types_args="$device_types_args --device-type $device_type"
done

get_artifact_name() {
    local artifact_name=$(jq -r '.artifact_provides.artifact_name' $1/header/header-info)
    echo $artifact_name
}

source_artifact_name=($(get_artifact_name $SOURCE_DIR_NAME))
target_artifact_name=($(get_artifact_name $TARGET_DIR_NAME))

xdelta3 -e -f \
    $XDELTA_FLAGS \
    -s $SOURCE_DIR_NAME/data/0000/*.ubifs \
    $TARGET_DIR_NAME/data/0000/*.ubifs \
    delta.ubifs

script_args=""
# For all files in the target artifact script directory
for script in $TARGET_DIR_NAME/header/scripts/*; do
    script_args="$script_args --script $script"
done

# Get target artifact file size
target_image_size=$(stat -c %s $TARGET_DIR_NAME/data/0000/*.ubifs)

# Write meta-data file
rm -f meta-data.json
echo '{ "target_image_size": "'$target_image_size'" }' > meta-data.json


delta_artifact_name="delta_${source_artifact_name}_${target_artifact_name}"

key_args=""
if [ -n "$SIGN_KEY_PATH" ]; then
    key_args="--key $SIGN_KEY_PATH"
fi

# Add --device-type argument for each device type
mender-artifact write module-image \
    --type "wifx-binary-delta" \
    $device_types_args \
    $script_args \
    $key_args \
    --artifact-name-depends $source_artifact_name \
    --artifact-name $target_artifact_name \
    --file delta.ubifs \
    --meta-data meta-data.json \
    --output-path $delta_artifact_name.mender


# Clean up
rm -rf $SOURCE_DIR_NAME $TARGET_DIR_NAME delta.ubifs meta-data.json

if [ -n "$EXTRACT_RESULT" ]; then
    extract_artifact $delta_artifact_name.mender $delta_artifact_name
fi

echo "Done"

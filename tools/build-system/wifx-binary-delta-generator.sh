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
#       - Input window size           -W  Default=8388608(8M)    [16384(16K) - 16777216(16M)]
#       - Instruction buffer size     -I  Default=32768(32KB)    [ min?      - 0 (Unlimited) ]
#       - Compression duplicates size -P  Default=262144(256KB)  P <= W, Must be power of 2
#       - Compression level           -9  Default=9              [0 - 9]
#   - SIGN_KEY_PATH  Path to the signing key to use for signing the delta artifact.
#   - TMP_DIR  Temporary directory to use for extracting artifacts.
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

XDELTA_FLAGS=${XDELTA_FLAGS:-"-B 67108864 -W 8388608 -I 32768 -P 262144 -9"}

TMP_DIR=${TMP_DIR:-$(mktemp -d)}

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

# Check dependencies
command -v jq >/dev/null 2>&1 || { echo "jq is required but not installed. Aborting." >&2; exit 1; }
command -v tar >/dev/null 2>&1 || { echo "tar is required but not installed. Aborting." >&2; exit 1; }
command -v xdelta3 >/dev/null 2>&1 || { echo "xdelta3 is required but not installed. Aborting." >&2; exit 1; }

SOURCE_DIR_NAME=$(basename $SOURCE_ARTIFACT_PATH .mender)
TARGET_DIR_NAME=$(basename $TARGET_ARTIFACT_PATH .mender)

SOURCE_FILE_NAME=$(basename -a --suffix=".mender" $SOURCE_ARTIFACT_PATH )
TARGET_FILE_NAME=$(basename -a --suffix=".mender" $TARGET_ARTIFACT_PATH )

TARGET_BASE_PATH=$(dirname $TARGET_ARTIFACT_PATH)

SOURCE_DIR_PATH="$TMP_DIR/$SOURCE_DIR_NAME"
TARGET_DIR_PATH="$TMP_DIR/$TARGET_DIR_NAME"

get_device_types() {
    artifact_dir_path=$1
    local device_types=$(jq -r '.artifact_depends.device_type[]' $artifact_dir_path/header/header-info)
    device_types=($device_types)
    echo "${device_types[@]}"
}

extract_artifact() {
    artifact_path=$1
    artifact_dir_path=$2
    mkdir "$artifact_dir_path"
    tar -xf "$artifact_path" -C "$artifact_dir_path"
    mkdir "$artifact_dir_path/header" && tar -xf "$artifact_dir_path/header.tar.gz" -C "$artifact_dir_path/header"
    mkdir -p "$artifact_dir_path/data/0000" && tar -xf "$artifact_dir_path/data/0000.tar.gz" -C "$artifact_dir_path/data/0000"
}

# Extract artifacts
extract_artifact $SOURCE_ARTIFACT_PATH $SOURCE_DIR_PATH
extract_artifact $TARGET_ARTIFACT_PATH $TARGET_DIR_PATH

# Find device types for both artifacts
source_device_types=($(get_device_types $SOURCE_DIR_PATH))
target_device_types=($(get_device_types $TARGET_DIR_PATH))

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
    artifact_dir_path=$1
    local artifact_name=$(jq -r '.artifact_provides.artifact_name' $artifact_dir_path/header/header-info)
    echo $artifact_name
}

source_artifact_name=($(get_artifact_name $SOURCE_DIR_PATH))
target_artifact_name=($(get_artifact_name $TARGET_DIR_PATH))


get_artifact_checksum() {
    artifact_dir_path=$1
    local artifact_checksum=$(jq -r '.artifact_provides."rootfs-image.checksum"' $artifact_dir_path/header/headers/0000/type-info)
    echo $artifact_checksum
}

source_artifact_checksum=($(get_artifact_checksum $SOURCE_DIR_PATH))
target_artifact_checksum=($(get_artifact_checksum $TARGET_DIR_PATH))

xdelta3 -e -f \
    $XDELTA_FLAGS \
    -s $SOURCE_DIR_PATH/data/0000/*.ubifs \
    $TARGET_DIR_PATH/data/0000/*.ubifs \
    "$TMP_DIR/delta.ubifs"

script_args=""
# For all files in the target artifact script directory
for script in $TARGET_DIR_PATH/header/scripts/*; do
    script_args="$script_args --script $script"
done

# Get target artifact file size
target_image_size=$(stat -c %s $TARGET_DIR_PATH/data/0000/*.ubifs)

# Write meta-data file
echo '{ "target_image_size": "'$target_image_size'" }' > "$TMP_DIR/meta-data.json"


delta_artifact_name="${TARGET_FILE_NAME}.delta-${SOURCE_FILE_NAME}.mender"

key_args=""
if [ -n "$SIGN_KEY_PATH" ]; then
    key_args="--key $SIGN_KEY_PATH"
fi

output_path="$TARGET_BASE_PATH/$delta_artifact_name"

# Add --device-type argument for each device type
mender-artifact write module-image \
    --type "wifx-binary-delta" \
    $device_types_args \
    $script_args \
    $key_args \
    --artifact-name-depends "$source_artifact_name" \
    --artifact-name "$target_artifact_name" \
    --depends "rootfs-image.checksum:$source_artifact_checksum" \
    --provides "rootfs-image.checksum:$target_artifact_checksum" \
    --provides "rootfs-image.version:$target_artifact_name" \
    --clears-provides "rootfs-image.*" \
    --file "$TMP_DIR/delta.ubifs" \
    --meta-data "$TMP_DIR/meta-data.json" \
    --output-path "$output_path"

# Cleanup
rm -rf $TMP_DIR

if [ -n "$EXTRACT_RESULT" ]; then
    extract_path="${output_path%.mender}" # Remove .mender extension
    rm -rf $extract_path
    extract_artifact $output_path $extract_path
fi

# Create metadata file containing filename / size / sha256 / depends in yaml format
meta_file="$output_path.meta"
{
    echo "type: delta-artifact"
    echo "depends:"
    echo "  rootfs-image.version: $source_artifact_name"
    echo "  rootfs-image.checksum: $source_artifact_checksum"
    echo "url: $delta_artifact_name"
    echo "sha256: $(sha256sum $output_path | cut -d ' ' -f 1)"
    echo "size: $(stat -c %s $output_path)"
} > "$meta_file"

echo "Delta artifact generated at $output_path"

#!/bin/bash -e
#
# generate-wifx-binary-delta.sh
#
# This script generates a binary delta between two Mender artifacts.
#
# Usage:
#   ./generate-wifx-binary-delta.sh <origin-artifact> <target-artifact>
#
# Arguments:
#   <origin-artifact>  Path to the origin Mender artifact.
#   <target-artifact>  Path to the target Mender artifact.
#
# Environment Variables:
#   - XDELTA_FLAGS  Additional flags to pass to xdelta3.
#       - Origin buffer size          -B  Default=67108864(64M)  [16384(16K) - Unlimited]
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
#   ./wifx-binary-delta-generator.sh origin.mender target.mender
#
# Author:
#   Wifx SA <info@iot.wifx.net>
#
# License:
#   All rights reserved.
#

XDELTA_FLAGS=${XDELTA_FLAGS:-"-B 67108864 -W 8388608 -I 32768 -P 262144 -9"}

TMP_DIR=${TMP_DIR:-$(mktemp -d)}

# Cleanup function
cleanup() {
    if [ -n "$TMP_DIR" ] && [ -d "$TMP_DIR" ]; then
        echo "Cleaning up temporary directory: $TMP_DIR" >&2
        rm -rf "$TMP_DIR"
    fi
}

# Set up cleanup trap to run on exit
trap cleanup EXIT INT TERM

ORIGIN_ARTIFACT_INPUT_PATH=$1
TARGET_ARTIFACT_INPUT_PATH=$2

# Preserve the caller-provided path for naming and output location.
# This keeps delta artifacts next to a target symlink instead of next to the
# dereferenced file it points to.
make_absolute_reference_path() {
    local input_path=$1

    if [[ "$input_path" = /* ]]; then
        printf '%s\n' "$input_path"
        return 0
    fi

    printf '%s/%s\n' "$PWD" "$input_path"
}

ORIGIN_ARTIFACT_REFERENCE_PATH=$(make_absolute_reference_path "$ORIGIN_ARTIFACT_INPUT_PATH")
TARGET_ARTIFACT_REFERENCE_PATH=$(make_absolute_reference_path "$TARGET_ARTIFACT_INPUT_PATH")

ORIGIN_ARTIFACT_PATH=$ORIGIN_ARTIFACT_INPUT_PATH
TARGET_ARTIFACT_PATH=$TARGET_ARTIFACT_INPUT_PATH

if [ -z "$ORIGIN_ARTIFACT_PATH" ] || [ -z "$TARGET_ARTIFACT_PATH" ]; then
    echo "Usage: $0 <origin-artifact> <target-artifact>" >&2
    exit 1
fi

# Convert to absolute paths and validate they don't contain problematic characters
ORIGIN_ARTIFACT_PATH=$(realpath "$ORIGIN_ARTIFACT_PATH" 2>/dev/null) || {
    echo "Error: Cannot resolve origin artifact path: '$1'" >&2
    exit 1
}

TARGET_ARTIFACT_PATH=$(realpath "$TARGET_ARTIFACT_PATH" 2>/dev/null) || {
    echo "Error: Cannot resolve target artifact path: '$2'" >&2
    exit 1
}

if [ ! -f "$ORIGIN_ARTIFACT_PATH" ]; then
    echo "Error: Origin artifact not found: $ORIGIN_ARTIFACT_PATH" >&2
    exit 1
fi

if [ ! -r "$ORIGIN_ARTIFACT_PATH" ]; then
    echo "Error: Origin artifact is not readable: $ORIGIN_ARTIFACT_PATH" >&2
    exit 1
fi

if [ ! -f "$TARGET_ARTIFACT_PATH" ]; then
    echo "Error: Target artifact not found: $TARGET_ARTIFACT_PATH" >&2
    exit 1
fi

if [ ! -r "$TARGET_ARTIFACT_PATH" ]; then
    echo "Error: Target artifact is not readable: $TARGET_ARTIFACT_PATH" >&2
    exit 1
fi

# Validate file extensions
if [[ ! "$ORIGIN_ARTIFACT_PATH" =~ \.mender$ ]]; then
    echo "Error: Origin artifact must have .mender extension" >&2
    exit 1
fi

if [[ ! "$TARGET_ARTIFACT_PATH" =~ \.mender$ ]]; then
    echo "Error: Target artifact must have .mender extension" >&2
    exit 1
fi

# Check dependencies
command -v jq >/dev/null 2>&1 || { echo "jq is required but not installed. Aborting." >&2; exit 1; }
command -v tar >/dev/null 2>&1 || { echo "tar is required but not installed. Aborting." >&2; exit 1; }
command -v xdelta3 >/dev/null 2>&1 || { echo "xdelta3 is required but not installed. Aborting." >&2; exit 1; }
command -v mender-artifact >/dev/null 2>&1 || { echo "mender-artifact is required but not installed. Aborting." >&2; exit 1; }

ORIGIN_DIR_NAME=$(basename "$ORIGIN_ARTIFACT_PATH" .mender)
TARGET_DIR_NAME=$(basename "$TARGET_ARTIFACT_PATH" .mender)

ORIGIN_FILE_NAME=$(basename "$ORIGIN_ARTIFACT_REFERENCE_PATH" .mender)
TARGET_FILE_NAME=$(basename "$TARGET_ARTIFACT_REFERENCE_PATH" .mender)

TARGET_BASE_PATH=$(dirname "$TARGET_ARTIFACT_REFERENCE_PATH")

ORIGIN_DIR_PATH="$TMP_DIR/$ORIGIN_DIR_NAME"
TARGET_DIR_PATH="$TMP_DIR/$TARGET_DIR_NAME"

get_device_types() {
    local artifact_dir_path=$1
    local header_info_path="$artifact_dir_path/header/header-info"
    
    if [ ! -f "$header_info_path" ]; then
        echo "Error: header-info file not found in $artifact_dir_path" >&2
        exit 1
    fi
    
    local device_types
    device_types=$(jq -r '.artifact_depends.device_type[]' "$header_info_path" 2>/dev/null) || {
        echo "Error: Failed to extract device types from $header_info_path" >&2
        exit 1
    }
    
    if [ -z "$device_types" ]; then
        echo "Error: No device types found in artifact" >&2
        exit 1
    fi
    
    device_types=($device_types)
    echo "${device_types[@]}"
}

extract_artifact() {
    local artifact_path=$1
    local artifact_dir_path=$2
    
    echo "Extracting artifact: $artifact_path" >&2
    
    mkdir -p "$artifact_dir_path" || {
        echo "Error: Failed to create directory $artifact_dir_path" >&2
        exit 1
    }
    
    tar -xf "$artifact_path" -C "$artifact_dir_path" || {
        echo "Error: Failed to extract main artifact $artifact_path" >&2
        exit 1
    }
    
    if [ ! -f "$artifact_dir_path/header.tar.gz" ]; then
        echo "Error: header.tar.gz not found in artifact $artifact_path" >&2
        exit 1
    fi
    
    mkdir -p "$artifact_dir_path/header" || {
        echo "Error: Failed to create header directory" >&2
        exit 1
    }
    
    tar -xf "$artifact_dir_path/header.tar.gz" -C "$artifact_dir_path/header" || {
        echo "Error: Failed to extract header from $artifact_path" >&2
        exit 1
    }
    
    if [ ! -f "$artifact_dir_path/data/0000.tar.gz" ]; then
        echo "Error: data/0000.tar.gz not found in artifact $artifact_path" >&2
        exit 1
    fi
    
    mkdir -p "$artifact_dir_path/data/0000" || {
        echo "Error: Failed to create data directory" >&2
        exit 1
    }
    
    tar -xf "$artifact_dir_path/data/0000.tar.gz" -C "$artifact_dir_path/data/0000" || {
        echo "Error: Failed to extract data from $artifact_path" >&2
        exit 1
    }
}

# Extract artifacts
extract_artifact "$ORIGIN_ARTIFACT_PATH" "$ORIGIN_DIR_PATH"
extract_artifact "$TARGET_ARTIFACT_PATH" "$TARGET_DIR_PATH"

# Find device types for both artifacts
origin_device_types=($(get_device_types "$ORIGIN_DIR_PATH"))
target_device_types=($(get_device_types "$TARGET_DIR_PATH"))

# Check that device types are the same for both artifacts
if [ "${origin_device_types[*]}" != "${target_device_types[*]}" ]; then
    echo "Error: Device types do not match between artifacts" >&2
    echo "  Origin device types: ${origin_device_types[*]}" >&2
    echo "  Target device types: ${target_device_types[*]}" >&2
    exit 1
fi

device_types_args=""
for device_type in "${target_device_types[@]}"; do
    device_types_args="$device_types_args --device-type $device_type"
done

get_artifact_name() {
    local artifact_dir_path=$1
    local header_info_path="$artifact_dir_path/header/header-info"
    
    if [ ! -f "$header_info_path" ]; then
        echo "Error: header-info file not found in $artifact_dir_path" >&2
        exit 1
    fi
    
    local artifact_name
    artifact_name=$(jq -r '.artifact_provides.artifact_name' "$header_info_path" 2>/dev/null) || {
        echo "Error: Failed to extract artifact name from $header_info_path" >&2
        exit 1
    }
    
    if [ -z "$artifact_name" ] || [ "$artifact_name" = "null" ]; then
        echo "Error: No artifact name found in $header_info_path" >&2
        exit 1
    fi
    
    echo "$artifact_name"
}

origin_artifact_name=$(get_artifact_name "$ORIGIN_DIR_PATH")
target_artifact_name=$(get_artifact_name "$TARGET_DIR_PATH")


get_artifact_checksum() {
    local artifact_dir_path=$1
    local type_info_path="$artifact_dir_path/header/headers/0000/type-info"
    
    if [ ! -f "$type_info_path" ]; then
        echo "Error: type-info file not found in $artifact_dir_path" >&2
        exit 1
    fi
    
    local artifact_checksum
    artifact_checksum=$(jq -r '.artifact_provides."rootfs-image.checksum"' "$type_info_path" 2>/dev/null) || {
        echo "Error: Failed to extract checksum from $type_info_path" >&2
        exit 1
    }
    
    if [ -z "$artifact_checksum" ] || [ "$artifact_checksum" = "null" ]; then
        echo "Error: No checksum found in $type_info_path" >&2
        exit 1
    fi
    
    echo "$artifact_checksum"
}

origin_artifact_checksum=$(get_artifact_checksum "$ORIGIN_DIR_PATH")
target_artifact_checksum=$(get_artifact_checksum "$TARGET_DIR_PATH")

# Find the ubifs files
origin_ubifs_file=$(find "$ORIGIN_DIR_PATH/data/0000" -name "*.ubifs" | head -1)
target_ubifs_file=$(find "$TARGET_DIR_PATH/data/0000" -name "*.ubifs" | head -1)

if [ -z "$origin_ubifs_file" ]; then
    echo "Error: No .ubifs file found in origin artifact" >&2
    exit 1
fi

if [ -z "$target_ubifs_file" ]; then
    echo "Error: No .ubifs file found in target artifact" >&2
    exit 1
fi

echo "Generating binary delta..." >&2
xdelta3 -e -f \
    $XDELTA_FLAGS \
    -s "$origin_ubifs_file" \
    "$target_ubifs_file" \
    "$TMP_DIR/delta.ubifs" || {
    echo "Error: Failed to generate binary delta with xdelta3" >&2
    exit 1
}

script_args=""
# For all files in the target artifact script directory
if [ -d "$TARGET_DIR_PATH/header/scripts" ]; then
    for script in "$TARGET_DIR_PATH/header/scripts"/*; do
        if [ -f "$script" ]; then
            script_args="$script_args --script $script"
        fi
    done
fi

# Get target artifact file size
target_image_size=$(stat -c %s "$target_ubifs_file") || {
    echo "Error: Failed to get file size of target ubifs file" >&2
    exit 1
}

# Write meta-data file
echo '{ "target_image_size": "'$target_image_size'" }' > "$TMP_DIR/meta-data.json"


delta_artifact_name="${TARGET_FILE_NAME}.delta-${ORIGIN_FILE_NAME}.mender"

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
    --artifact-name-depends "$origin_artifact_name" \
    --artifact-name "$target_artifact_name" \
    --depends "rootfs-image.checksum:$origin_artifact_checksum" \
    --provides "rootfs-image.checksum:$target_artifact_checksum" \
    --provides "rootfs-image.version:$target_artifact_name" \
    --clears-provides "rootfs-image.*" \
    --file "$TMP_DIR/delta.ubifs" \
    --meta-data "$TMP_DIR/meta-data.json" \
    --output-path "$output_path"

# Cleanup will be handled by the trap function

if [ -n "$EXTRACT_RESULT" ]; then
    extract_path="${output_path%.mender}" # Remove .mender extension
    rm -rf "$extract_path"
    extract_artifact "$output_path" "$extract_path"
fi

# Create metadata file containing filename / size / sha256 / depends in yaml format
meta_file="$output_path.meta"
{
    echo "type: delta-artifact"
    echo "depends:"
    echo "  rootfs-image.version: $origin_artifact_name"
    echo "  rootfs-image.checksum: $origin_artifact_checksum"
    echo "url: $delta_artifact_name"
    echo "sha256: $(sha256sum "$output_path" | cut -d ' ' -f 1)"
    echo "size: $(stat -c %s "$output_path")"
} > "$meta_file"

echo "Delta artifact generated at $output_path"

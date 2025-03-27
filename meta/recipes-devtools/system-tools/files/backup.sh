#!/bin/bash

set -e

# Utility functions
fail() {
    echo "Critical failure: $1" >&2
    exit 1
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        fail "This script must be run as root."
    fi
}

check_commands() {
    REQUIRED_COMMANDS=("date" "mktemp" "tar" "cp" "mv" "machine-info" "manager" "fw_setenv" "mount" "dd" "grep" "cut" "sed" "reboot")
    for cmd in "${REQUIRED_COMMANDS[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            fail "Required command '$cmd' is not installed."
        fi
    done
}

create_temp_dir() {
    mktemp -d
}

extract_metadata() {
    local archive="$1"
    local temp_dir="$2"

    echo "Validating archive contents..."
    if ! tar -tzf "$archive" ./metadata &> /dev/null; then
        echo "Archive contents:"
        tar -tzf "$archive" || fail "Failed to list archive contents."
        fail "Required metadata files (./metadata) are missing in the archive."
    fi

    tar --strip-components=1 -xzf "$archive" -C "$temp_dir" ./metadata || fail "Failed to extract metadata from archive."
}

compare_metadata() {
    local origin_file="$1"
    local target_file="$2"
    local key="$3"
    local origin_value
    local target_value

    origin_value=$(grep "^$key=" "$origin_file" | cut -d'=' -f2)
    target_value=$(grep "^$key=" "$target_file" | cut -d'=' -f2)

    if [ "$origin_value" != "$target_value" ]; then
        fail "Mismatch for $key. Origin: $origin_value, Target: $target_value"
    fi
}

# Set backup archive version
BACKUP_ARCHIVE_VERSION=1

build_metadata() {
    local output_file="$1"
    [ -z "$output_file" ] && fail "Output file path is required for build_metadata."

    {
        echo "# Metadata generated on $(date)"
        echo "BACKUP_ARCHIVE_VERSION=$BACKUP_ARCHIVE_VERSION"
        echo "PRODUCT_BRAND=$(machine-info read PRODUCT_BRAND)"
        echo "YOCTO_MACHINE=$(machine-info read YOCTO_MACHINE)"
        echo "PRODUCT_LORA_REGION=$(machine-info read PRODUCT_VARIANT_ATTR_LORA_REGION)"
        echo "OS_VERSION=$(manager -o json system os | grep '"versionNormalized"' | sed -E 's/.*"versionNormalized"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/')"
    } > "$output_file" || fail "Failed to write metadata to $output_file."
}

# Backup create function
create() {
    local output_dir="${1:-$(pwd)}"
    local archive_name="${2:-backup_$(date +%Y%m%d-%H%M%S).tar.gz}"
    local config_overlay_path="/var/lib/os/layers/active/config"

    [ -d "$output_dir" ] || mkdir -p "$output_dir"

    local temp_dir
    temp_dir=$(create_temp_dir)
    local backup_temp_path="$temp_dir/backup"
    mkdir -p "$backup_temp_path/files"

    echo "Collecting system metadata..."
    build_metadata "$backup_temp_path/metadata"

    echo "Backing up configuration files..."
    [ -d "$config_overlay_path" ] && cp -ra "$config_overlay_path"/* "$backup_temp_path/files" || fail "Configuration directory $config_overlay_path does not exist."

    echo "Creating backup archive..."
    find "$backup_temp_path/files" -type c -printf "%P\n" > "$backup_temp_path/hot_restore_exclude"
    tar -czf "$temp_dir/$archive_name" -C "$backup_temp_path" .
    mv "$temp_dir/$archive_name" "$output_dir/$archive_name"

    local file_count
    file_count=$(find "$backup_temp_path/files" -type f | wc -l)
    local archive_size
    archive_size=$(du -h "$output_dir/$archive_name" | cut -f1)

    rm -rf "$temp_dir"

    echo "Backup completed successfully!"
    echo "Archive location: $output_dir/$archive_name"
    echo "Number of files backed up: $file_count"
    echo "Total backup size: $archive_size"
}

# Backup restore function
restore() {
    local archive="$1"
    local restore_type="${2:-full}" # Default to full restore if no type is specified

    [ -z "$archive" ] && fail "Usage: $0 restore <archive_to_restore> [full|hot]"

    local temp_dir
    temp_dir=$(create_temp_dir)
    extract_metadata "$archive" "$temp_dir"

    echo "Checking compatibility..."
    local origin_metadata_file="$temp_dir/metadata"
    local target_metadata_file="$temp_dir/target-metadata"
    build_metadata "$target_metadata_file"

    # Check backup archive version compatibility
    local archive_version
    archive_version=$(grep "^BACKUP_ARCHIVE_VERSION=" "$origin_metadata_file" | cut -d'=' -f2)
    if [ "$archive_version" != "$BACKUP_ARCHIVE_VERSION" ]; then
        fail "Incompatible backup archive version. Expected: $BACKUP_ARCHIVE_VERSION, Found: $archive_version"
    fi

    compare_metadata "$origin_metadata_file" "$target_metadata_file" "PRODUCT_BRAND"
    compare_metadata "$origin_metadata_file" "$target_metadata_file" "YOCTO_MACHINE"
    compare_metadata "$origin_metadata_file" "$target_metadata_file" "PRODUCT_LORA_REGION"
    compare_metadata "$origin_metadata_file" "$target_metadata_file" "OS_VERSION"


    if [ "$restore_type" = "hot" ]; then
        echo "Performing hot restore..."

        # Extract hot_restore_exclude file
        local hot_restore_exclude_path="$temp_dir/hot_restore_exclude"
        tar --strip-components=1 -xzf "$archive" -C "$temp_dir" ./hot_restore_exclude || fail "Failed to extract hot_restore_exclude file."
        
        if ! tar -xzf "$archive" -C /etc --strip-components=2 --exclude-from="$hot_restore_exclude_path" ./files/; then
            echo "Archive contents:"
            tar -tzf "$archive" || fail "Failed to list archive contents."
            fail "Failed to restore config."
        fi
    else
        echo "Performing full restore..."
        echo "Preparing restore environment..."
        local layer_config_rw="/var/lib/restore/config"
        mkdir -p "$layer_config_rw"
        mount --bind /var/lib/os/layers/inactive/config "$layer_config_rw"
        mount -o remount,rw -t ubifs "$layer_config_rw"

        LAYERS_DIR=/var/lib/os/layers/active
        MOUNT=$(mount)
        PATTERN="ubi0_([01]) on $LAYERS_DIR/factory"

        if [[ $MOUNT =~ $PATTERN ]]; then
            ACTIVE_PART=${BASH_REMATCH[1]}
            FACTORY_ACTIVE="ubi0_$ACTIVE_PART"
            FACTORY_INACTIVE="ubi0_$((1 - $ACTIVE_PART))"
        else
            echo "Error: Unable to determine active and inactive partitions."
            exit 1
        fi

        echo "Performing factory overlay binary copy from active to inactive partition..."
        FACTORY_ACTIVE_SIZE=$(ubinfo /dev/$FACTORY_ACTIVE | grep "Size:" | awk -F'[()]' '{print $2}' | awk '{print $1}' || fail "Failed to determine size of active partition.")
        if ! dd if=/dev/$FACTORY_ACTIVE | ubiupdatevol /dev/$FACTORY_INACTIVE -s "$FACTORY_ACTIVE_SIZE" -; then
            fail "Failed to copy factory overlay binary from active to inactive partition."
        fi

        if ! dd if=/dev/$FACTORY_ACTIVE | cmp - <(dd if=/dev/$FACTORY_INACTIVE); then
            fail "Verification of factory overlay binary copy failed."
        fi
        echo "Factory overlay binary copy done."

        echo "Cleanup config layer..."
        rm -rf "$layer_config_rw"/*

        echo "Restoring config layer..."
        if ! tar -xzf "$archive" -C "$layer_config_rw" --strip-components=2 ./files/; then
            echo "Archive contents:"
            tar -tzf "$archive" || fail "Failed to list archive contents."
            fail "Failed to restore config layer. Ensure the 'files' directory exists in the archive."
        fi

        echo "Switching to the restored system..."
        fw_setenv mender_boot_part $ACTIVE_PART
        fw_setenv mender_boot_part_hex $ACTIVE_PART
        fw_setenv upgrade_available 1

        # Cleanup
        umount "$layer_config_rw"
        rm -rf "$layer_config_rw"
    fi

    rm -rf "$temp_dir"

    if [ "$restore_type" = "hot" ]; then
        echo "The hot restoration is complete. Reboot the system to make new configurations effective. Reboot now? [y/N]"
    else
        echo "The full restoration is complete. Reboot the system to apply changes. Reboot now? [y/N]"
    fi

    read -r reboot
    [ "$reboot" = "y" ] && reboot
}

# Main script execution
check_root
check_commands

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <command> [arguments]"
    echo "Commands:"
    echo "  create [output_directory] [archive_name] - Create a backup"
    echo "  restore <archive_to_restore> [full|hot] - Restore from a backup (full or hot)"
    exit 1
fi

command="$1"
shift

case "$command" in
    create)
        create "$@"
        ;;
    restore)
        restore "$@"
        ;;
    *)
        fail "Unknown command '$command'"
        ;;
esac

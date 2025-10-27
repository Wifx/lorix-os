#!/bin/bash
# Copyright (c) 2025, Wifx Sàrl <info@wifx.net>
# All rights reserved.

# Persistent logs management script - saves/restores logs to persistent storage

# Configuration variables with defaults
PERSISTENT_LOG_FILE="${PERSISTENT_LOG_FILE:-/data/persistent-logs.tar.gz}"
LOG_DIR="${LOG_DIR:-/var/log}"
COMPRESSION="${COMPRESSION:-yes}"
COMPRESSION_RATIO_PERCENT="${COMPRESSION_RATIO_PERCENT:-70}"

# Color output functions
info() {
    echo -e "\033[32m[INFO]\033[0m $1"
}

warn() {
    echo -e "\033[33m[WARN]\033[0m $1"
}

error() {
    echo -e "\033[31m[ERROR]\033[0m $1"
}

# Format size in KB to human readable format (kB or MB with decimal)
format_size() {
    local size_kb="$1"
    
    if [ "${size_kb}" -lt 1024 ]; then
        echo "${size_kb}kB"
    else
        local size_mb_int=$((size_kb / 1024))
        if [ "${size_mb_int}" -lt 10 ]; then
            # For sizes < 10MB, show one decimal place
            local size_mb_decimal=$(awk "BEGIN {printf \"%.1f\", ${size_kb}/1024}")
            echo "${size_mb_decimal}MB"
        else
            # For sizes >= 10MB, show integer MB
            echo "${size_mb_int}MB"
        fi
    fi
}

validate_config() {
    # Check if compression ratio is valid
    if ! [[ "${COMPRESSION_RATIO_PERCENT}" =~ ^[0-9]+$ ]] || [ "${COMPRESSION_RATIO_PERCENT}" -lt 0 ] || [ "${COMPRESSION_RATIO_PERCENT}" -gt 100 ]; then
        error "Invalid COMPRESSION_RATIO_PERCENT: ${COMPRESSION_RATIO_PERCENT}. Must be between 0 and 100."
        return 1
    fi
    
    # Check if compression setting is valid
    if [ "${COMPRESSION}" != "yes" ] && [ "${COMPRESSION}" != "no" ]; then
        error "Invalid COMPRESSION: ${COMPRESSION}. Must be 'yes' or 'no'."
        return 1
    fi
    
    return 0
}

print_config() {
    info "Configuration:"
    info "  Persistent log file: ${PERSISTENT_LOG_FILE}"
    info "  Log directory: ${LOG_DIR}"
    info "  Compression: ${COMPRESSION}"
    if [ "${COMPRESSION}" = "yes" ]; then
        info "  Expected compression ratio: ${COMPRESSION_RATIO_PERCENT}%"
    fi
}


# Save functionality

cmd_save() {
    info "Saving logs from ${LOG_DIR} to persistent storage"
    
    # Ensure persistent storage parent directory exists
    local persistent_dir=$(dirname "${PERSISTENT_LOG_FILE}")
    if [ ! -d "${persistent_dir}" ]; then
        info "Creating persistent log directory ${persistent_dir}"
        mkdir -p "${persistent_dir}"
        if [ $? -ne 0 ]; then
            error "Failed to create persistent log directory"
            return 1
        fi
    fi
    
    # Delete existing archive if it exists (only one archive allowed)
    if [ -f "${PERSISTENT_LOG_FILE}" ]; then
        info "Removing existing archive (only one archive allowed)"
        rm -f "${PERSISTENT_LOG_FILE}"
    fi

    # If log directory is a symlink, resolve to actual path
    if [ -L "${LOG_DIR}" ]; then
        local resolved_log_dir
        resolved_log_dir=$(readlink -f "${LOG_DIR}")
        if [ -n "${resolved_log_dir}" ]; then
            LOG_DIR="${resolved_log_dir}"
        fi
    fi

    # Check if log directory exists and has content
    if [ ! -d "${LOG_DIR}" ] || [ -z "$(ls -A "${LOG_DIR}" 2>/dev/null)" ]; then
        info "No logs to save"
        return 0
    fi
    
    # Calculate the size of logs to be archived
    local logs_size_kb=$(du -sk "${LOG_DIR}" 2>/dev/null | cut -f1)
    local logs_size_mb=$((logs_size_kb / 1024))
    
    # Estimate compressed archive size based on configured compression ratio
    local estimated_archive_size_kb=${logs_size_kb}
    if [ "${COMPRESSION}" = "yes" ]; then
        # Calculate remaining size after compression (100 - compression_ratio_percent)
        local remaining_percent=$((100 - COMPRESSION_RATIO_PERCENT))
        estimated_archive_size_kb=$((logs_size_kb * remaining_percent / 100))
    fi
    local estimated_archive_size_mb=$((estimated_archive_size_kb / 1024))
    
    # Check available space on persistent storage
    local persistent_dir_parent=$(dirname "${PERSISTENT_LOG_FILE}")
    local available_space_kb=$(df "${persistent_dir_parent}" | awk 'NR==2 {print $4}')
    local available_space_mb=$((available_space_kb / 1024))
    
    # Check if there's enough space for the estimated archive
    if [ ${available_space_mb} -lt ${estimated_archive_size_mb} ]; then
        warn "Insufficient space on persistent storage:"
        warn "  Log directory size: $(format_size ${logs_size_kb})"
        warn "  Estimated archive size: $(format_size ${estimated_archive_size_kb})"
        warn "  Available space: $(format_size ${available_space_kb})"
        return 1
    fi
    
    info "Log size: $(format_size ${logs_size_kb}), estimated archive: $(format_size ${estimated_archive_size_kb}), available: $(format_size ${available_space_kb})"
    
    # Determine compression and tar options based on file extension
    local tar_opts=""
    if [[ "${PERSISTENT_LOG_FILE}" == *.tar.gz ]]; then
        tar_opts="czf"
    elif [[ "${PERSISTENT_LOG_FILE}" == *.tar ]]; then
        tar_opts="cf"
    else
        # Default based on compression setting
        if [ "${COMPRESSION}" = "yes" ]; then
            tar_opts="czf"
        else
            tar_opts="cf"
        fi
    fi
    
    # Create the archive
    if tar ${tar_opts} "${PERSISTENT_LOG_FILE}" -C "${LOG_DIR}" . 2>/dev/null; then
        # Verify the archive was created and get its actual size
        if [ -f "${PERSISTENT_LOG_FILE}" ]; then
            local actual_archive_size_kb=$(du -k "${PERSISTENT_LOG_FILE}" | cut -f1)
            local actual_archive_size_mb=$((actual_archive_size_kb / 1024))
            local compression_ratio=0
            
            if [ ${logs_size_kb} -gt 0 ]; then
                compression_ratio=$(((logs_size_kb - actual_archive_size_kb) * 100 / logs_size_kb))
            fi
            
            info "Archive created successfully:"
            info "  File: $(basename "${PERSISTENT_LOG_FILE}")"
            info "  Original size: $(format_size ${logs_size_kb})"
            info "  Archive size: $(format_size ${actual_archive_size_kb})"
            if [[ "${PERSISTENT_LOG_FILE}" == *.tar.gz ]] || ([ "${COMPRESSION}" = "yes" ] && [[ "${PERSISTENT_LOG_FILE}" != *.tar ]]); then
                info "  Compression ratio: ${compression_ratio}%"
            fi
            
            # Final space check after archive creation
            local remaining_space_kb=$(df "${persistent_dir_parent}" | awk 'NR==2 {print $4}')
            info "  Remaining space: $(format_size ${remaining_space_kb})"
            
            return 0
        else
            warn "Archive file was not created properly"
            return 1
        fi
    else
        warn "Failed to create log archive"
        return 1
    fi
}

# Restore functionality
cmd_restore() {
    info "Restoring persistent logs from ${PERSISTENT_LOG_FILE} to ${LOG_DIR}"
    
    # Check if persistent log file exists
    if [ ! -f "${PERSISTENT_LOG_FILE}" ]; then
        info "No persistent log file found at ${PERSISTENT_LOG_FILE}"
        return 0
    fi

    # Ensure log directory exists
    mkdir -p "${LOG_DIR}"
    if [ $? -ne 0 ]; then
        error "Failed to create log directory ${LOG_DIR}"
        return 1
    fi
    
    info "Restoring logs from $(basename "${PERSISTENT_LOG_FILE}")"
    
    # Determine extraction method based on file extension
    local extract_success=0
    case "${PERSISTENT_LOG_FILE}" in
        *.tar.gz)
            if tar -xzf "${PERSISTENT_LOG_FILE}" -C "${LOG_DIR}" 2>/dev/null; then
                extract_success=1
            fi
            ;;
        *.tar)
            if tar -xf "${PERSISTENT_LOG_FILE}" -C "${LOG_DIR}" 2>/dev/null; then
                extract_success=1
            fi
            ;;
        *)
            # Try to detect format automatically
            if tar -tf "${PERSISTENT_LOG_FILE}" >/dev/null 2>&1; then
                if tar -xf "${PERSISTENT_LOG_FILE}" -C "${LOG_DIR}" 2>/dev/null; then
                    extract_success=1
                fi
            fi
            ;;
    esac
    
    if [ ${extract_success} -eq 1 ]; then
        info "Successfully restored logs"
        
        # Delete the archive after successful restore
        info "Deleting restored archive $(basename "${PERSISTENT_LOG_FILE}")"
        rm -f "${PERSISTENT_LOG_FILE}"
    else
        warn "Failed to restore $(basename "${PERSISTENT_LOG_FILE}")"
        return 1
    fi
    
    return 0
}

# Show help
show_help() {
    echo "Usage: $0 COMMAND [OPTIONS]"
    echo ""
    echo "Persistent logs management script (single archive mode)"
    echo ""
    echo "Commands:"
    echo "  save                 Save logs to persistent storage"
    echo "  restore              Restore logs from persistent storage"
    echo "  config               Show current configuration"
    echo ""
    echo "Global options:"
    echo "  --help, -h           Show this help message"
    echo ""
    echo "Environment variables:"
    echo "  PERSISTENT_LOG_FILE        Persistent log archive file (default: /data/persistent-logs.tar.gz)"
    echo "  LOG_DIR                    Log directory (default: /var/log)"
    echo "  COMPRESSION                Enable compression (default: yes)"
    echo "  COMPRESSION_RATIO_PERCENT  Expected compression ratio (default: 70)"
    echo ""
    echo "Examples:"
    echo "  $0 save                    Save current logs to persistent file"
    echo "  $0 restore                 Restore logs from persistent file"
    echo "  $0 restore --list          Show persistent archive status"
    echo "  $0 config                  Show current configuration"
}

# Main execution
main() {
    # Validate configuration first
    if ! validate_config; then
        exit 1
    fi
    
    # Check if no arguments provided
    if [ $# -eq 0 ]; then
        error "No command specified"
        echo ""
        show_help
        exit 1
    fi
    
    # Parse global options and command
    local command=""
    while [[ $# -gt 0 ]]; do
        case $1 in
            save|restore|config)
                command="$1"
                shift
                break
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                error "Unknown command or option: $1"
                echo ""
                show_help
                exit 1
                ;;
        esac
    done
    
    # Execute command
    case "${command}" in
        save)
            cmd_save "$@"
            exit $?
            ;;
        restore)
            cmd_restore "$@"
            exit $?
            ;;
        config)
            print_config
            exit 0
            ;;
        *)
            error "Invalid command: ${command}"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Run main function if script is executed directly
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi
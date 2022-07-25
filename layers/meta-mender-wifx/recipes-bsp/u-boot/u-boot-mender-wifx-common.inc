# Copyright (c) 2022, Wifx Sarl <info@iot.wifx.net>
# All rights reserved.

# UBI specific version of the fw_env.config file.
mender_create_fw_env_config_file_mender-ubi() {
    # Takes one argument, which is the file to put it in.

    set -x

    # fw-utils seem to only be able to handle hex values.
    HEX_PARTITION_OFFSET_1="$(printf 0x%x "${MENDER_UBOOT_ENV_STORAGE_PARTITION_OFFSET_1}")"
    HEX_PARTITION_OFFSET_2="$(printf 0x%x "${MENDER_UBOOT_ENV_STORAGE_PARTITION_OFFSET_2}")"
    HEX_BOOTENV_SIZE="$(printf 0x%x "${BOOTENV_SIZE}")"
    HEX_LEB_SIZE="$(printf 0x%x "${MENDER_UBI_LEB_SIZE}")"
    HEX_PEB_SIZE="$(printf 0x%x "${MENDER_STORAGE_PEB_SIZE}")"

    # For flash sector size param, we use PEB size instead of LEB size as we
    # manage env on raw NAND without UBI support.

    # create fw_env.config file
    cat > $1 <<EOF
/dev/${MENDER_UBOOT_ENV_STORAGE_DEVICE_1} $HEX_PARTITION_OFFSET_1 $HEX_BOOTENV_SIZE $HEX_PEB_SIZE ${UBOOT_ENV_SECTOR_COUNT}
/dev/${MENDER_UBOOT_ENV_STORAGE_DEVICE_2} $HEX_PARTITION_OFFSET_2 $HEX_BOOTENV_SIZE $HEX_PEB_SIZE ${UBOOT_ENV_SECTOR_COUNT}
EOF
}
mender_create_fw_env_config_file_mender-ubi[vardeps] += " \
    MENDER_UBOOT_ENV_STORAGE_DEVICE_1 \
    MENDER_UBOOT_ENV_STORAGE_DEVICE_2 \
    MENDER_UBOOT_ENV_STORAGE_PARTITION_OFFSET_1 \
    MENDER_UBOOT_ENV_STORAGE_PARTITION_OFFSET_2 \
    BOOTENV_SIZE \
    MENDER_UBI_LEB_SIZE \
    MENDER_STORAGE_PEB_SIZE \
    UBOOT_ENV_SECTOR_COUNT \
"

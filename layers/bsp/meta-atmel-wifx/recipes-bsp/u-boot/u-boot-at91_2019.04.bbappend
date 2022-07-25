# Copyright (c) 2022, Wifx Sarl <info@iot.wifx.net>
# All rights reserved.

require u-boot-at91-common_2019.04.inc

FILESEXTRAPATHS_prepend := "${THISDIR}/files/:"

ENV_FILENAME = "u-boot-env.bin"

COMPATIBLE_MACHINE = "sama5d4-wifx"

# meta-atmel already creates the U-Boot env file but without redundant info so
# we need to recreate it with -r option.
do_compile_append() {
    if [ -e "${ENV_FILEPATH}/${MACHINE}.txt" ]; then
        echo "Compile U-Boot environment for ${MACHINE}"
        ${B}/tools/mkenvimage -s ${UBOOT_ENV_SIZE} -r ${ENV_FILEPATH}/${MACHINE}.txt -o ${ENV_FILENAME}
    else
        echo "No custom environment available for ${MACHINE}."
    fi
}

do_deploy_append() {
    if [ -e "${ENV_FILEPATH}/${MACHINE}.txt" ]; then
        install -Dm 0644 "${ENV_FILEPATH}/${MACHINE}.txt" "${DEPLOYDIR}/u-boot-env-${MACHINE}.txt"
    fi
}

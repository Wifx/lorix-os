# Copyright (c) 2019-2020, Wifx Sàrl <info@wifx.net>
# All rights reserved.

# Class used to create an archive image for Wifx products and the Wifx programming tool

inherit image image_types

# Default variables
KERNEL_IMAGETYPE ?= "zImage"

ARCHIVE_DIR ?= "${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.wimg"
TEMPDIR = "${WORKDIR}/temp_wimg"

IMAGE_TYPES += " wimg"

do_image_wimg[depends] += "zip-native:do_populate_sysroot virtual/firststage:do_populate_sysroot virtual/bootloader:do_populate_sysroot virtual/kernel:do_populate_sysroot mtd-utils-native:do_populate_sysroot"
IMAGE_TYPEDEP_wimg_append = " ubimg"
IMAGE_NAME_SUFFIX = ""

do_compress_zip () {
    cd ${TEMPDIR}
    zip -r ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.wimg .
}

IMAGE_CMD_wimg () {
    # Delete previous temp directory if exists
    if [ -d ${TEMPDIR} ]; then
        rm -rf ${TEMPDIR}
    fi
    mkdir -p ${TEMPDIR}

    # Copy first state bootloader into the archive directory
    cp ${DEPLOY_DIR_IMAGE}/at91bootstrap.bin ${TEMPDIR}

    # Copy bootloader into the archive directory
    cp ${DEPLOY_DIR_IMAGE}/u-boot.bin ${TEMPDIR}

    # Copy bootloader environment into the archive directory
    cp ${DEPLOY_DIR_IMAGE}/u-boot-env.bin ${TEMPDIR}

    # Copy rootfs into the archive directory
    cp ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.ubimg ${TEMPDIR}/rootfs.ubi

    # Create the metadata configuration file
    cat > ${TEMPDIR}/metadata.yml <<EOF
version: 1.0

device:
  products:
    - ${MACHINE}
  arch: SAMA5D4
  nand:
    ioset: 1
    busWidth: 8
    header: ${WIMG_DEVICE_NAND_HEADER}
    eraseBlockSize: ${WIMG_DEVICE_ERASE_BLK}

partitions:
  - label: "AT91bootstrap"
    image: at91bootstrap.bin
    startAddress: 0x00000000
    checksum-md5: $(md5sum ${TEMPDIR}/at91bootstrap.bin | awk '{ print $1 }')
    isBoot: true

  - label: "U-boot"
    image: u-boot.bin
    startAddress: 0x00040000
    checksum-md5: $(md5sum ${TEMPDIR}/u-boot.bin | awk '{ print $1 }')

  - label: "U-boot env"
    image: u-boot-env.bin
    startAddress: 0x00100000
    size: 0x80000
    checksum-md5: $(md5sum ${TEMPDIR}/u-boot-env.bin | awk '{ print $1 }')

  - label: "RootFS"
    image: rootfs.ubi
    startAddress: 0x00180000
    size: end
    checksum-md5: $(md5sum ${TEMPDIR}/rootfs.ubi | awk '{ print $1 }')
EOF

    # Apply the zip compression
    do_compress_zip

    rm -rf ${IMGDEPLOYDIR}/release/*.wimg
    ln -sr ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.wimg ${IMGDEPLOYDIR}/release/${RELEASE_ARTIFACT_NAME}_${MACHINE}.wimg
}
do_image_wimg[dirs] = "${IMGDEPLOYDIR}/release"

# So that we can use the files from excluded paths in the full images.
do_image_wimg[respect_exclude_path] = "0"
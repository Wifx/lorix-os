# Copyright (c) 2019-2020, Wifx SA <info@wifx.net>
# All rights reserved.

# Class used to create an archive image for Wifx products and the Wifx programming tool

inherit image image_types

# Default variables
KERNEL_IMAGETYPE ?= "zImage"

IMAGE_TYPES += " wimg"

do_image_wimg[depends] += "zip-native:do_populate_sysroot virtual/firststage:do_populate_sysroot virtual/bootloader:do_populate_sysroot virtual/kernel:do_populate_sysroot mtd-utils-native:do_populate_sysroot"
IMAGE_TYPEDEP:wimg:append = " ubimg"
IMAGE_NAME_SUFFIX = ""

IMAGE_CMD:wimg () {
    # Copy first state bootloader into the archive directory
    cp ${DEPLOY_DIR_IMAGE}/at91bootstrap.bin ${_WIMG_TEMP_WORKDIR}

    # Copy bootloader into the archive directory
    cp ${DEPLOY_DIR_IMAGE}/u-boot.bin ${_WIMG_TEMP_WORKDIR}

    # Copy bootloader environment into the archive directory
    cp ${DEPLOY_DIR_IMAGE}/u-boot-env.bin ${_WIMG_TEMP_WORKDIR}

    # Copy rootfs into the archive directory
    cp ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.ubimg ${_WIMG_TEMP_WORKDIR}/rootfs.ubi

    # Create the metadata configuration file
    cat > ${_WIMG_TEMP_WORKDIR}/metadata.yml <<EOF
version: 1.0

device:
  products:
${@wifx_wimg_machine_products_list_yml(d, 2)}
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
    checksum-md5: $(md5sum ${_WIMG_TEMP_WORKDIR}/at91bootstrap.bin | awk '{ print $1 }')
    isBoot: true

  - label: "U-boot"
    image: u-boot.bin
    startAddress: 0x00040000
    checksum-md5: $(md5sum ${_WIMG_TEMP_WORKDIR}/u-boot.bin | awk '{ print $1 }')

  - label: "U-boot env"
    image: u-boot-env.bin
    startAddress: 0x00100000
    size: 0x80000
    checksum-md5: $(md5sum ${_WIMG_TEMP_WORKDIR}/u-boot-env.bin | awk '{ print $1 }')

  - label: "RootFS"
    image: rootfs.ubi
    startAddress: 0x00180000
    size: end
    checksum-md5: $(md5sum ${_WIMG_TEMP_WORKDIR}/rootfs.ubi | awk '{ print $1 }')
EOF

    # We keep track of latest generated metadata file
    cp ${_WIMG_TEMP_WORKDIR}/metadata.yml ${WORKDIR}/wimg.metadata.yml

    # Apply the zip compression
    do_compress_zip

    chmod 0644 "${WORKDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.wimg"
    mv "${WORKDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.wimg" "${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.wimg"

    # Link in release directory with distribution name and version
    rm -rf ${IMGDEPLOYDIR}/release/*.wimg
    ln -sr ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.wimg ${IMGDEPLOYDIR}/release/${RELEASE_ARTIFACT_NAME}_${MACHINE}.wimg
}
do_image_wimg[dirs] = "${IMGDEPLOYDIR}/release"
do_image_wimg[prefuncs] += " wifx_wimg_create_temp_workdir"
do_image_wimg[postfuncs] += " wifx_wimg_delete_temp_workdir"

do_compress_zip () {
    cd ${_WIMG_TEMP_WORKDIR}
    zip -r ${WORKDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.wimg .
}

python wifx_wimg_create_temp_workdir() {
    import os
    import subprocess

    _temp_workdir = os.path.realpath(os.path.join(d.getVar("WORKDIR"), "wimg.temp_workdir"))

    # Remove eventual previously existing working directory
    subprocess.check_call(["rm", "-rf", _temp_workdir])
    if os.path.exists(_temp_workdir):
        bb.fatal('Could not remove working directory for wimg generation ("%s")' % _temp_workdir)

    subprocess.check_call(["mkdir", "-p", _temp_workdir])

    d.setVar('_WIMG_TEMP_WORKDIR', _temp_workdir)
}

python wifx_wimg_delete_temp_workdir() {
    import subprocess

    _temp_workdir = d.getVar('_WIMG_TEMP_WORKDIR')

    subprocess.check_call(["rm", "-rf", _temp_workdir])
}

def wifx_wimg_machine_products_list_yml(d, indent):
    import os
    import subprocess

    products_list = d.getVar("MACHINE_PRODUCTS_LIST")
    if not products_list:
        bb.fatal("List of supported products is not defined for the current machine, please define MACHINE_PRODUCTS_LIST var in machine conf file")

    list = products_list.split()
    length = len(list)

    output = ""
    for i in range(length):
      output += " " * indent * 2 + "- " + list[i]
      if i < length - 1:
        output += os.linesep
    return output

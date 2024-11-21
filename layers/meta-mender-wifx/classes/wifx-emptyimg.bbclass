# Copyright (c) 2022, Wifx Sarl <info@iot.wifx.net>
# All rights reserved.

# Class to create the "emptyimg" type, which contains an empty partition.

IMAGE_CMD:emptyimg() {
    mkfs.ubifs -o "${WORKDIR}/emptyimg.ubifs" -r "${_EMPTYIMG_TEMP_WORKDIR}" ${MKUBIFS_ARGS}
    chmod 0644 "${WORKDIR}/emptyimg.ubifs"
    mv "${WORKDIR}/emptyimg.ubifs" "${IMGDEPLOYDIR}/${IMAGE_NAME}.emptyimg"
}

do_image_emptyimg[depends] += "mtd-utils-native:do_populate_sysroot"
do_image_emptyimg[prefuncs] += " wifx_emptyimg_create_temp_workdir"
do_image_emptyimg[postfuncs] += " wifx_emptyimg_delete_temp_workdir"

python wifx_emptyimg_create_temp_workdir() {
    import os
    import subprocess

    _temp_workdir = os.path.realpath(os.path.join(d.getVar("WORKDIR"), "emptyimg.temp_workdir"))

    # Remove eventual previously existing working directory
    subprocess.check_call(["rm", "-rf", _temp_workdir])
    if os.path.exists(_temp_workdir):
        bb.fatal('Could not remove working directory for emptyimg generation ("%s")' % _temp_workdir)

    subprocess.check_call(["mkdir", "-p", _temp_workdir])

    d.setVar('_EMPTYIMG_TEMP_WORKDIR', _temp_workdir)
}

python wifx_emptyimg_delete_temp_workdir() {
    import subprocess

    _temp_workdir = d.getVar('_EMPTYIMG_TEMP_WORKDIR')

    subprocess.check_call(["rm", "-rf", _temp_workdir])
}
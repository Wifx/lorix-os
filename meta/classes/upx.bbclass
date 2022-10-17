DEPENDS += "upx-native"

python do_compress() {
    import subprocess

    PN = d.getVar('PN')
    WORKDIR = d.getVar('WORKDIR')

    UPX_COMPRESS_FILES_RAW = d.getVar('UPX_COMPRESS_FILES_' + PN)
    if UPX_COMPRESS_FILES_RAW is not None:
        UPX_COMPRESS_FILES = UPX_COMPRESS_FILES_RAW.strip().split()

        for path in UPX_COMPRESS_FILES:
            fullpath = f"{WORKDIR}/packages-split/{PN}{path}"
            try:
                subprocess.run(f"upx {fullpath} --no-progress", shell=True)
                subprocess.run(f"upx -t {fullpath}", shell=True)
            except subprocess.CalledProcessError as error:
                bb.fatal("Cannot compress file '%s' : %s" % (fullpath, error.output))
            except Exception as error:
                bb.fatal("Cannot compress file '%s' : %s" % (fullpath, error))
    else:
        bb.warn('No file to compress have been defined but upx has been inherited. You should define UPX_COMPRESS_FILES_${PN} or remove upx inheritance.')
}

addtask compress after do_package do_package_qa do_assets_deploy before do_deploy
do_compress[vardeps] += "UPX_COMPRESS_FILES_${PN}"
do_build[recrdeptask] += "do_compress"

EXPORT_FUNCTIONS do_compress

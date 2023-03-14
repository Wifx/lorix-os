DEPENDS_append = " upx-native"

python package_do_compress() {
    import subprocess

    compress = d.getVar('COMPRESS_BINARIES_UPX')
    if compress == "true":
        bb.note("UPX compression is enabled")
    else:
        bb.note("UPX compression is disabled (%s)" % compress)
        return

    pn = d.getVar('PN')
    pkgd = d.getVar('PKGD')

    if d.getVar('UPX_COMPRESSION_LEVEL') is None:
        compression_level = ""
    else:
        compression_level = f"-{UPX_COMPRESSION_LEVEL}"

    UPX_COMPRESS_FILES_RAW = d.getVar('UPX_COMPRESS_FILES_' + pn)
    if UPX_COMPRESS_FILES_RAW is not None:
        compress_files = UPX_COMPRESS_FILES_RAW.strip().split()

        for path in compress_files:
            fullpath = f"{pkgd}{path}"
            bb.note(f"compressing {fullpath}...")
            try:
                subprocess.run(f"upx {fullpath} {compression_level} -q", shell=True)
                subprocess.run(f"upx -t {fullpath}", shell=True)
            except subprocess.CalledProcessError as error:
                bb.fatal("cannot compress file '%s' : %s" % (fullpath, error.output))
            except Exception as error:
                bb.fatal("cannot compress file '%s' : %s" % (fullpath, error))
    else:
        bb.warn('No file to compress have been defined but upx has been inherited. You should define UPX_COMPRESS_FILES_${PN} or remove upx inheritance.')
}

PACKAGEBUILDPKGD += "package_do_compress"

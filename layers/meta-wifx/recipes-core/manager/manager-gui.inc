SUMMARY = "LORIX Manager GUI for unified centralized management"
DESCRIPTION = "Provides the LORIX Manager web GUI files to be served by the daemon over HTTP"
AUTHOR = "Wifx Sàrl"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=7b29896a760c7f57013dc1412764b30c"

PROVIDES = "manager-gui"
RDEPENDS_${PN}  += "manager"

S = "${WORKDIR}/git"
B = "${WORKDIR}/git/dist"

inherit unpack-online-assets

python do_install() {
    import os
    import shutil

    gui_source=d.expand("${B}")
    gui_dest=d.expand("${D}${servicedir}/manager")

    # GUI web files
    os.makedirs(gui_dest, exist_ok=True)

    for path, dirs, files in os.walk(gui_source):
        relative_path=path.replace(gui_source+'/', '').replace(gui_source, '')
        for directory in dirs:
            dirpath = os.path.join(gui_dest, relative_path, directory)
            bb.note("Creating directory '%s'" % dirpath)
            os.mkdir(dirpath)

        for file in files:
            filename=file.replace('.woff', '').replace('.eot.gz', '').replace('.eot.gz', '').replace('.ttf.gz', '')
            if os.path.isfile(os.path.join(path, file) + ".gz") or os.path.isfile(os.path.join(path, filename) + ".woff2"):
                bb.note("'%s' install was skipped, preferring compressed version" % file)
            else:
                bb.note("Installing '%s' to '%s'" % (file, os.path.join(gui_dest, relative_path)))
                shutil.copy(os.path.join(path, file), os.path.join(gui_dest, relative_path, file))

    # Install license file into web sources directory
    shutil.copy(os.path.join(d.expand("${S}"), "LICENSE"), os.path.join(gui_dest))
}

FILES_${PN} = "${servicedir}/manager/*"

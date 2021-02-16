inherit wifx-tools

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
    file://LICENSE \
    file://base-feeds_lorix-one.conf.template \
"
LIC_FILES_CHKSUM = "file://LICENSE;md5=0835ade698e0bcf8506ecda2f7b4f302"

DEPENDS += "os-release sed-native"

python do_generate_base_feeds() {
    import shutil

    # Retrieve os-release values
    source_shell_param_file(d.expand('${STAGING_DIR_TARGET}${libdir}/os-release'), d)

    # Copy the motd template file to have a clean file on each iteration
    shutil.copy2(d.expand('${WORKDIR}/base-feeds_lorix-one.conf.template'), d.expand('${WORKDIR}/base-feeds_lorix-one.conf'))

    # Retrieve the URL base feeds
    url = d.getVar('DISTRO_RELEASE_BASE_URL')
    if not url:
        bb.fatal("DISTRO_RELEASE_BASE_URL variable is not defined, please define it in distro conf")

    # Add leading / if not present
    if url.endswith('/'):
        url = url[:-1]
    url += '/feeds'

    machine = d.getVar('MACHINE')
    if not machine:
        bb.fatal("MACHINE field is not defined, please add it in os-release")
    machine_url = machine.replace('-', '_')

    pkg_arch = d.getVar('TUNE_PKGARCH')

    # Populate motd file with version, hash and date
    string = open(d.expand('${WORKDIR}/base-feeds_lorix-one.conf'),'r').read()
    string = string.replace('@{DISTRO_PACKAGES_FEEDS_BASE_URL}', url)
    string = string.replace('@{LORIX_MACHINE}', machine)
    string = string.replace('@{LORIX_MACHINE_URL}', machine_url)
    string = string.replace('@{PKG_ARCH}', pkg_arch)

    f = open(d.expand('${WORKDIR}/base-feeds_lorix-one.conf'),'w')
    f.write(string)
    f.close()
}
addtask do_generate_base_feeds before do_install after do_unpack
do_generate_base_feeds[depends] += "os-release:do_populate_sysroot"

do_install_append() {
    install -d ${D}${sysconfdir}/opkg
    install -m 0644 ${WORKDIR}/base-feeds_lorix-one.conf ${D}${sysconfdir}/opkg/base-feeds.conf
}

CONFFILES_${PN}_append = "${sysconfdir}/opkg/base-feeds.conf"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://0001-Moved-binary-hardware-database-location-from-etc-ude.patch"

do_install_append() {
    # Remove useless and big hardware configuration files
    rm -f ${D}${sysconfdir}/udev/hwdb.d/20-OUI.hwdb
    rm -f ${D}${sysconfdir}/udev/hwdb.d/20-pci-classes.hwdb
    rm -f ${D}${sysconfdir}/udev/hwdb.d/20-pci-vendor-model.hwdb
    # Move hardware configuration files from /etc/udev/hwdb.d to /lib/udev/hwdb.d
    # This is ugly and would be better to modify configure and Makefile to install
    # the *.hwdb files directly into the right dir but too much effort.
    install -m 0755 -d ${D}${base_libdir}/udev
    mv ${D}${sysconfdir}/udev/hwdb.d ${D}${base_libdir}/udev/hwdb.d
    # Recreate empty directory for local user eudev hardware conf files
    install -m 0755 -d ${D}${sysconfdir}/udev/hwdb.d
}
FILES_eudev-hwdb = "${base_libdir}/udev/hwdb.d"

# Modify hwdb location
EXTRA_OECONF += "--with-hwdbbindir=${base_libdir}/udev"

pkg_postinst_eudev-hwdb () {
    if test -n "$D"; then
        ${@qemu_run_binary(d, '$D', '${bindir}/udevadm')} hwdb --update --root $D
        chown root:root $D${base_libdir}/udev/hwdb.bin
    else
        udevadm hwdb --update
    fi
}

pkg_prerm_eudev-hwdb () {
        rm -f $D${base_libdir}/udev/hwdb.bin
}
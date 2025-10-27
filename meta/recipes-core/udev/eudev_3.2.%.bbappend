FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://0001-Moved-binary-hardware-database-location-from-etc-ude.patch"

do_install:append() {
    ## Remove useless and big hardware configuration files

    # Vendors/names
    rm -f ${D}${sysconfdir}/udev/hwdb.d/20-acpi-vendor.hwdb
    rm -f ${D}${sysconfdir}/udev/hwdb.d/20-bluetooth-vendor-product.hwdb
    rm -f ${D}${sysconfdir}/udev/hwdb.d/20-OUI.hwdb
    rm -f ${D}${sysconfdir}/udev/hwdb.d/20-pci-classes.hwdb
    rm -f ${D}${sysconfdir}/udev/hwdb.d/20-pci-vendor-model.hwdb
    rm -f ${D}${sysconfdir}/udev/hwdb.d/20-usb-vendor-model.hwdb
    # Specific USB vendor models support for Wifx's products
    cat > ${D}${sysconfdir}/udev/hwdb.d/20-usb-vendor-model.hwdb << 'EOF'
usb:v1782*
 ID_VENDOR_FROM_DATABASE=Spreadtrum Communications Inc.

usb:v1782p4d10*
 ID_MODEL_FROM_DATABASE=MC610

usb:v1782p4d11*
 ID_MODEL_FROM_DATABASE=MC610

usb:v1D6B*
 ID_VENDOR_FROM_DATABASE=Linux Foundation

usb:v1D6Bp0001*
 ID_MODEL_FROM_DATABASE=1.1 root hub

usb:v1D6Bp0002*
 ID_MODEL_FROM_DATABASE=2.0 root hub
EOF

    # Input peripherals
    rm -f ${D}${sysconfdir}/udev/hwdb.d/60-autosuspend-fingerprint-reader.hwdb
    rm -f ${D}${sysconfdir}/udev/hwdb.d/60-sensor.hwdb
    rm -f ${D}${sysconfdir}/udev/hwdb.d/60-keyboard.hwdb
    rm -f ${D}${sysconfdir}/udev/hwdb.d/70-mouse.hwdb
    rm -f ${D}${sysconfdir}/udev/hwdb.d/70-pointingstick.hwdb
    rm -f ${D}${sysconfdir}/udev/hwdb.d/70-touchpad.hwdb

    # Specialized peripherals
    rm -f ${D}${sysconfdir}/udev/hwdb.d/70-analyzers.hwdb
    rm -f ${D}${sysconfdir}/udev/hwdb.d/70-av-production.hwdb
    rm -f ${D}${sysconfdir}/udev/hwdb.d/70-cameras.hwdb
    rm -f ${D}${sysconfdir}/udev/hwdb.d/70-joystick.hwdb
    rm -f ${D}${sysconfdir}/udev/hwdb.d/70-pda.hwdb
    rm -f ${D}${sysconfdir}/udev/hwdb.d/80-ieee1394-unit-function.hwdb

    # Screen support, not required
    rm -f ${D}${sysconfdir}/udev/hwdb.d/60-evdev.hwdb
    rm -f ${D}${sysconfdir}/udev/hwdb.d/60-input-id.hwdb

    # Move hardware configuration files from /etc/udev/hwdb.d to /lib/udev/hwdb.d
    # This is ugly and would be better to modify configure and Makefile to install
    # the *.hwdb files directly into the right dir but too much effort.
    install -m 0755 -d ${D}${base_libdir}/udev
    mv ${D}${sysconfdir}/udev/hwdb.d ${D}${base_libdir}/udev/hwdb.d
    # Recreate empty directory for local user eudev hardware conf files
    install -m 0755 -d ${D}${sysconfdir}/udev/hwdb.d
}
FILES:${PN}-hwdb = "${base_libdir}/udev/hwdb.d"

# Modify hwdb location
EXTRA_OECONF += "--with-hwdbbindir=${base_libdir}/udev"

pkg_postinst:${PN}-hwdb () {
    $INTERCEPT_DIR/postinst_intercept update_udev_hwdb ${PKG} mlprefix=${MLPREFIX} binprefix=${MLPREFIX}
}

pkg_prerm:${PN}-hwdb () {
    rm -f $D${base_libdir}/udev/hwdb.bin
}

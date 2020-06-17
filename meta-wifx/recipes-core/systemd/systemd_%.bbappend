PACKAGECONFIG_remove += " \
    backlight \
    hibernate \
    vconsole \
    manpages \
"

do_install_append() {
    # Set the maximium size of runtime journal to 32M as default instead of 64M
	sed -i -e 's/.*RuntimeMaxUse.*/RuntimeMaxUse=32M/' ${D}${sysconfdir}/systemd/journald.conf
}

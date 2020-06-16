do_install_append() {
    # setuid bit to allow all users using ping command without sudo
    chmod 4755 ${D}${base_bindir}/ping
}

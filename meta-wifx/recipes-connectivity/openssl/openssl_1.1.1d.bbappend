do_install_append () {
	# Create symlinks from lib[ssl/crypto]1.0.0 to lib[ssl/crypto]1.1 to keep compatibility
	ln -srnf ${libdir}/libssl.so.1.1 ${D}${libdir}/libssl.so.1.0.0
	ln -srnf ${libdir}/libcrypto.so.1.1 ${D}${libdir}/libcrypto.so.1.0.0
}

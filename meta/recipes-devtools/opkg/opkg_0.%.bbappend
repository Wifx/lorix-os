do_install:append () {
	echo "option no_install_recommends 1" >>${D}${sysconfdir}/opkg/opkg.conf

	ln -sf ${OPKGSTATUSDIR}/status ${D}${OPKGLIBDIR}/opkg/status
}

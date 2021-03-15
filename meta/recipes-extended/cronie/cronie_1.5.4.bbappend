FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
	file://crontab_override \
"

do_install_append() {
	install -m 0755 ${WORKDIR}/crontab_override ${D}${sysconfdir}/crontab
	chmod 600 ${D}${sysconfdir}/crontab
}

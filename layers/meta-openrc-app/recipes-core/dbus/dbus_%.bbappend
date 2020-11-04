FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://dbus.initd"

inherit openrc

OPENRC_SERVICE_${PN} = "dbus"
OPENRC_RUNLEVEL_dbus = "default"

do_install_append() {
	if [ "${PN}" = "${BPN}" ]; then
		# Install startup files
		install -d -m 755 ${D}${OPENRC_INITDIR}
		install -m 755 ${WORKDIR}/dbus.initd ${D}${OPENRC_INITDIR}/dbus
	fi
}

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://dbus.initd"

inherit openrc

OPENRC_SERVICES:${PN} = "dbus"
OPENRC_RUNLEVEL:dbus = "default"

do_install:append() {
	if [ "${PN}" = "${BPN}" ]; then
		# Install startup files
		install -d -m 755 ${D}${OPENRC_INITDIR}
		install -m 755 ${WORKDIR}/dbus.initd ${D}${OPENRC_INITDIR}/dbus
	fi
}

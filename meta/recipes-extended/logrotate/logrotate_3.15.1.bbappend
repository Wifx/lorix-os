DEPDENDS_${PN} += "cronie"
RDEPENDS_${PN} += "cronie"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
    file://logrotate.cron \
"

do_install_append() {
    install -d -m 755 ${D}${sysconfdir}/cron.d
    install -p -m 0644 ${WORKDIR}/logrotate.cron ${D}${sysconfdir}/cron.d/logrotate

    install -d -m 755 ${D}${sbindir}
    install -p -m 0755 ${S}/examples/logrotate.cron ${D}${sbindir}/logrotate.sh
}

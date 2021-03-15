
do_install_append() {
    mkdir -p ${D}${sysconfdir}/cron.hourly
    install -p -m 0755 ${S}/examples/logrotate.cron ${D}${sysconfdir}/cron.hourly/logrotate
}

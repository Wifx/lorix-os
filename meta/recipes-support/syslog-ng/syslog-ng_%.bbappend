FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
    file://syslog-ng.conf \
    file://scl/local-file/persistent-file.conf \
    file://scl/local-file/volatile-file.conf \
    file://rules/general.conf \
    file://rules/applicative.conf \
    file://rules/errors.conf \
    file://rules/system.conf \
    file://rules/manager.conf \
    file://syslog-ng.logrotate \
"

PACKAGECONFIG = " \
    ${@bb.utils.filter('DISTRO_FEATURES', 'ipv6', d)} \
    http \
    json \
"

do_install:append() {
    install -d ${D}/${sysconfdir}/${PN}/

    install -m 644 ${WORKDIR}/syslog-ng.conf  ${D}/${sysconfdir}/${PN}/syslog-ng.conf

    # scl
    install -d ${D}/${sysconfdir}/${PN}/scl/
    install -d ${D}/${sysconfdir}/${PN}/scl/local-file/
    install -m 644 ${WORKDIR}/scl/local-file/persistent-file.conf  ${D}/${sysconfdir}/${PN}/scl/local-file/persistent-file.conf
    install -m 644 ${WORKDIR}/scl/local-file/volatile-file.conf    ${D}/${sysconfdir}/${PN}/scl/local-file/volatile-file.conf

    # rules
    install -d ${D}/${sysconfdir}/${PN}/conf.d/
    install -m 644 ${WORKDIR}/rules/general.conf        ${D}/${sysconfdir}/${PN}/conf.d/general.conf
    install -m 644 ${WORKDIR}/rules/applicative.conf    ${D}/${sysconfdir}/${PN}/conf.d/applicative.conf
    install -m 644 ${WORKDIR}/rules/errors.conf         ${D}/${sysconfdir}/${PN}/conf.d/errors.conf
    install -m 644 ${WORKDIR}/rules/system.conf         ${D}/${sysconfdir}/${PN}/conf.d/system.conf
    install -m 644 ${WORKDIR}/rules/manager.conf        ${D}/${sysconfdir}/${PN}/conf.d/manager.conf

    # logrotate
    install -d ${D}/${sysconfdir}/logrotate.d/

    install -m 644 ${WORKDIR}/syslog-ng.logrotate  ${D}/${sysconfdir}/logrotate.d/logs
}

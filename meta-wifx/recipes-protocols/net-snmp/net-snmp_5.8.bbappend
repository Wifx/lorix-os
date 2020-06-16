# Copyright (c) 2019-2020, Wifx Sàrl <info@wifx.net>
# All rights reserved.

SRC_URI += " \
    file://99_net-snmp \
    "

# We want to avoid including support for PCI interface since we have an error at start because we don't have PCI
do_configure_append() {
    sed -e "s|#define HAVE_PCI_LOOKUP_NAME 1|/* #undef HAVE_PCI_LOOKUP_NAME */|g" \
        -e "s|#define HAVE_PCI_PCI_H 1|/* #undef HAVE_PCI_PCI_H */|g" \
            -i ${S}/include/net-snmp/net-snmp-config.h
}

do_install_append() {
    install -d ${D}${sysconfdir}/default/volatiles
    install -m 0644 ${WORKDIR}/99_net-snmp ${D}${sysconfdir}/default/volatiles
}

FILES_${PN}-server-snmpd += " \
    ${sysconfdir}/default/volatiles/99_net-snmp \
"

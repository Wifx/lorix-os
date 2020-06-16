PACKAGECONFIG = "dbus"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://10-use-dnsmasq.conf"

do_install_append() {
    # Install default configuration files for the NetworkManager
    install -d ${D}${sysconfdir}/NetworkManager/conf.d
    install -m 0644 ${WORKDIR}/10-use-dnsmasq.conf ${D}${sysconfdir}/NetworkManager/conf.d/10-use-dnsmasq.conf
}

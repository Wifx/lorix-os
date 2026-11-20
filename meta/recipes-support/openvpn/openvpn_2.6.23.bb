# Copy of meta-networking (scarthgap) openvpn_2.6.14.bb updated to 2.6.23, which fixes
# CVE-2026-12932 (tls-crypt-v2 memory leak) and CVE-2026-11771 (NTLMv2 proxy overrun).
# CVE-2025-13086.patch dropped: included upstream since 2.6.16.
# Remove once meta-openembedded scarthgap ships >= 2.6.23.

SUMMARY = "A full-featured SSL VPN solution via tun device."
HOMEPAGE = "https://openvpn.net/"
SECTION = "net"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=89196bacc47ed37a5b242a535661a049"
DEPENDS = "lzo lz4 openssl iproute2 libcap-ng ${@bb.utils.contains('DISTRO_FEATURES', 'pam', 'libpam', '', d)}"

inherit autotools systemd update-rc.d pkgconfig

SRC_URI = "http://swupdate.openvpn.org/community/releases/${BP}.tar.gz \
           file://0001-configure.ac-eliminate-build-path-from-openvpn-versi.patch \
           file://openvpn \
          "

UPSTREAM_CHECK_URI = "https://openvpn.net/community-downloads"

SRC_URI[sha256sum] = "4041c709162bec1325abf5aa8cf27a255cc477c634b15ee310411c701fc40a96"

CVE_STATUS[CVE-2020-27569] = "not-applicable-config: Applies only Aviatrix OpenVPN client, not openvpn"
CVE_STATUS[CVE-2025-13751] = "not-applicable-platform: The vulnerability is Windows specific"

INITSCRIPT_PACKAGES = "${PN}"
INITSCRIPT_NAME:${PN} = "openvpn"
INITSCRIPT_PARAMS:${PN} = "start 10 2 3 4 5 . stop 70 0 1 6 ."

CFLAGS += "-fno-inline"

# I want openvpn to be able to read password from file (hrw)
EXTRA_OECONF += "--enable-iproute2"
EXTRA_OECONF += "${@bb.utils.contains('DISTRO_FEATURES', 'pam', '', '--disable-plugin-auth-pam', d)}"

# Explicitly specify IPROUTE to bypass the configure-time check for /sbin/ip on the host.
EXTRA_OECONF += "IPROUTE=${base_sbindir}/ip"

EXTRA_OECONF += "SYSTEMD_UNIT_DIR=${systemd_system_unitdir} \
                 TMPFILES_DIR=${nonarch_libdir}/tmpfiles.d \
                "

PACKAGECONFIG ??= "${@bb.utils.filter('DISTRO_FEATURES', 'systemd', d)} \
                   ${@bb.utils.filter('DISTRO_FEATURES', 'selinux', d)} \
                  "

PACKAGECONFIG[systemd] = "--enable-systemd,--disable-systemd,systemd"
PACKAGECONFIG[selinux] = "--enable-selinux,--disable-selinux,libselinux"

do_install:append() {
    install -d ${D}/${sysconfdir}/init.d
    install -m 755 ${WORKDIR}/openvpn ${D}/${sysconfdir}/init.d

    install -d ${D}/${sysconfdir}/openvpn
    install -d ${D}/${sysconfdir}/openvpn/server
    install -d ${D}/${sysconfdir}/openvpn/client

    install -d ${D}/${sysconfdir}/openvpn/sample
    install -m 644 ${S}/sample/sample-config-files/loopback-server  ${D}${sysconfdir}/openvpn/sample/loopback-server.conf
    install -m 644 ${S}/sample/sample-config-files/loopback-client  ${D}${sysconfdir}/openvpn/sample/loopback-client.conf
    install -dm 755 ${D}${sysconfdir}/openvpn/sample/sample-config-files
    install -dm 755 ${D}${sysconfdir}/openvpn/sample/sample-keys
    install -dm 755 ${D}${sysconfdir}/openvpn/sample/sample-scripts
    install -m 644 ${S}/sample/sample-config-files/* ${D}${sysconfdir}/openvpn/sample/sample-config-files
    install -m 644 ${S}/sample/sample-keys/* ${D}${sysconfdir}/openvpn/sample/sample-keys
    install -m 644 ${S}/sample/sample-scripts/* ${D}${sysconfdir}/openvpn/sample/sample-scripts

    install -d -m 710 ${D}/${localstatedir}/lib/openvpn
}

PACKAGES =+ " ${PN}-sample "

RRECOMMENDS:${PN} = "kernel-module-tun"

FILES:${PN}-dbg += "${libdir}/openvpn/plugins/.debug"
FILES:${PN} += "${systemd_system_unitdir}/openvpn-server@.service \
                ${systemd_system_unitdir}/openvpn-client@.service \
                ${nonarch_libdir}/tmpfiles.d \
               "
FILES:${PN}-sample = "${sysconfdir}/openvpn/sample/ \
                     "

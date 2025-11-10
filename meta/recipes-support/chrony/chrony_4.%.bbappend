FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += " \
    file://chrony.conf \
    file://nm-dispatcher \
    file://custom-servers.sources \
    file://default-pool.sources \
"

do_install:append() {

    # Custom source files
    install -d ${D}${sysconfdir}/chrony/sources.d
    install -m 0644 ${WORKDIR}/custom-servers.sources ${D}${sysconfdir}/chrony/sources.d/
    install -m 0644 ${WORKDIR}/default-pool.sources ${D}${sysconfdir}/chrony/sources.d/

    # NetworkManager dispatcher scripts
    install -d ${D}${sysconfdir}/NetworkManager/dispatcher.d
    install -m 0755 ${WORKDIR}/nm-dispatcher ${D}${sysconfdir}/NetworkManager/dispatcher.d/20-chrony-ntp
}

FILES:chronyc += " \
    ${sysconfdir}/chrony/sources.d/custom-servers.sources \
    ${sysconfdir}/chrony/sources.d/default-pool.sources \
    ${sysconfdir}/NetworkManager/dispatcher.d/20-chrony-ntp \
"

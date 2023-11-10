FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " file://interfaces.ifupdown"

inherit update-alternatives

ALTERNATIVE_PRIORITY = "50"
ALTERNATIVE:${PN} = "net.interfaces"
ALTERNATIVE_LINK_NAME[net.interfaces] = "${sysconfdir}/network/interfaces"
ALTERNATIVE_TARGET[net.interfaces] = "${sysconfdir}/network/alternatives/interfaces.ifupdown"

do_install:append(){
	# Remove original network/interfaces files
	rm -rf ${D}${sysconfdir}/network/interfaces

	# Replace it by the update alternatives one
	install -d ${D}${sysconfdir}/network/alternatives
	install -m 0644 ${WORKDIR}/interfaces.ifupdown ${D}${sysconfdir}/network/alternatives/interfaces.ifupdown
}

CONFFILES:${PN} = "${sysconfdir}/network/alternatives/interfaces.ifupdown"

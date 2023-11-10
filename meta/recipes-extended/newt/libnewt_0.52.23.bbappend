# doesn't support Pie flags
SECURITY_CFLAGS:pn-${PN} = "${SECURITY_NOPIE_CFLAGS}"
SECURITY_LDFLAGS:pn-${PN} = ""

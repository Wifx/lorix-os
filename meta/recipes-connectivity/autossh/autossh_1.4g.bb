require autossh.inc

PR = "r0"
LIC_FILES_CHKSUM = "file://autossh.c;beginline=1;endline=26;md5=3bd8d1f3c318208902b778054d74e70b"
SRC_URI[md5sum] = "2b804bc1bf6d2f2afaa526d02df7c0a2"
SRC_URI[sha256sum] = "5fc3cee3361ca1615af862364c480593171d0c54ec156de79fc421e31ae21277"

# It supports now DESTDIR during install step.
EXTRA_OEMAKE = "DESTDIR=${D}"

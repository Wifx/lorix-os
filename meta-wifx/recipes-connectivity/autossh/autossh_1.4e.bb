require autossh.inc

PR = "r0"
LIC_FILES_CHKSUM = "file://autossh.c;beginline=1;endline=24;md5=755a81ffe573faf6c18d1f1061d097c4"
SRC_URI[md5sum] = "f86684b96e99d22b2e9d35dc63b0aa29"
SRC_URI[sha256sum] = "9e8e10a59d7619176f4b986e256f776097a364d1be012781ea52e08d04679156"

# autossh --prefix and --exec-prefix are buggy and install step fail.
# We need then to override every used directory options
# It doesn't support neither install DESTDIR.
EXTRA_OECONF = " \
    --prefix=${D}${prefix} \
    --exec_prefix=${D} \
    --bindir=${D}${bindir} \
    --datadir=${D}${datadir} \
    --mandir=${D}${mandir} \
"

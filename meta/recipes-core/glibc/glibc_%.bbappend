FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# Security fixes backported from release/2.41/master (not on release/2.39/master).
# Drop each patch once poky's glibc SRCREV includes it.
#  - CVE-2026-5450: one-byte heap overflow in scanf %mc/%mC with width > 1024
#  - CVE-2026-5928: ungetwc compares against the byte stream instead of the wide stream
SRC_URI += " \
    file://0001-stdio-common-Fix-buffer-overflow-in-scanf-mc-BZ-34008.patch \
    file://0002-libio-Fix-ungetwc-operating-on-byte-stream-BZ-33998.patch \
"

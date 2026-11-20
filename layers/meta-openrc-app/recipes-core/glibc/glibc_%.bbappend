FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# CVE-2026-5450: one-byte heap overflow in scanf %mc/%mC with width > 1024.
# Fixed upstream on release/2.41 only; drop this once poky's glibc SRCREV includes it.
SRC_URI += "file://0001-stdio-common-Fix-buffer-overflow-in-scanf-mc-BZ-34008.patch"

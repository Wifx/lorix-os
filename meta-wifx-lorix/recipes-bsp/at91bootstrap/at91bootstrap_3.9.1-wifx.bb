require at91bootstrap.inc

LIC_FILES_CHKSUM = "file://main.c;endline=27;md5=a2a70db58191379e2550cbed95449fbd"

# Indicative hash
SRCREV = "2a5f7f8464f631d8095c24ac1e5e8fc32e93c284"

# Remove "-wifx" from package version to get Atmel's sources version
ATMEL_VERSION = "${@d.getVar('PV', True).replace('-wifx', '')}"

SRC_URI += " \
    https://github.com/linux4sam/at91bootstrap/archive/v${ATMEL_VERSION}.tar.gz;name=tarball \
    file://0001-Change-revision-to-wifx.patch \
    file://0002-Add-LORIX-One-support.patch \
"

S = "${WORKDIR}/${PN}-${ATMEL_VERSION}"

SRC_URI[tarball.md5sum] = "6c3f965490b1e08097af308c4595e217"
SRC_URI[tarball.sha256sum] = "17b0ed7f906188a0d213727e44de6f4dd063df0fecae6286da9cd6933839fd4c"

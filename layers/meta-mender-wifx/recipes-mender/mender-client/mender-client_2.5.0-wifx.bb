require mender-client.inc

################################################################################
#-------------------------------------------------------------------------------
# THINGS TO CONSIDER FOR EACH RELEASE:
# - SRC_URI (particularly "branch")
# - SRCREV
# - DEFAULT_PREFERENCE
#-------------------------------------------------------------------------------

SRC_URI = "git://github.com/Wifx/mender;protocol=https;branch=2.5.x-wifx"

# Tag: 2.5.0
SRCREV = "00a2b4ea2f18bac503031305a67c75ede3316857"

# Enable this in Betas, not in finals.
# Downprioritize this recipe in version selections.
#DEFAULT_PREFERENCE = "-1"

################################################################################

# DO NOT change the checksum here without make sure that ALL licenses (including
# dependencies) are included in the LICENSE variable below.
LIC_FILES_CHKSUM = "file://src/github.com/mendersoftware/mender/LIC_FILES_CHKSUM.sha256;md5=94f3ba4eba45eae14396f3499fcb5383"
LICENSE = "Apache-2.0 & BSD-2-Clause & BSD-3-Clause & ISC & MIT & OLDAP-2.8"

DEPENDS += "xz openssl"
RDEPENDS_${PN} += "liblzma openssl"

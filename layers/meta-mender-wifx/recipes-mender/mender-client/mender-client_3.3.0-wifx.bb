require mender-client-wifx.inc

################################################################################
#-------------------------------------------------------------------------------
# THINGS TO CONSIDER FOR EACH RELEASE:
# - SRC_URI (particularly "branch")
# - SRCREV
# - DEFAULT_PREFERENCE
#-------------------------------------------------------------------------------

SRC_URI = "git://github.com/Wifx/mender;protocol=https;branch=3.3.x-wifx"

# Tag: 3.3.0-wifx
SRCREV = "27558d5b37074b3f5806f54bccfdf7fdf9e8a532"

# Enable this in Betas, and in branches that cannot carry this major version as
# default.
# Downprioritize this recipe in version selections.
#DEFAULT_PREFERENCE = "-1"

################################################################################

# DO NOT change the checksum here without make sure that ALL licenses (including
# dependencies) are included in the LICENSE variable below. Note that for
# releases, we must check the LIC_FILES_CHKSUM.sha256 file, not the LICENSE
# file.
LIC_FILES_CHKSUM = "file://src/github.com/mendersoftware/mender/LIC_FILES_CHKSUM.sha256;md5=4c90b9581dcc07bd0d0c6e680a60a86f"
LICENSE = "Apache-2.0 & BSD-2-Clause & BSD-3-Clause & ISC & MIT & OLDAP-2.8 & OpenSSL"

DEPENDS += "xz openssl"
RDEPENDS_${PN} += "liblzma openssl"

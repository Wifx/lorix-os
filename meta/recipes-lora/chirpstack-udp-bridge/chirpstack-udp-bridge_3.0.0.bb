require chirpstack-udp-bridge.inc

SRCREV = "${AUTOREV}"
SRC_URI += "git://github.com/brocaar/chirpstack-concentratord.git;protocol=git;branch=udp_forwarder"
PR = "r1"

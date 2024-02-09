require chirpstack-concentratord-v3.inc

SRC_URI += " \
    git://github.com/brocaar/chirpstack-concentratord.git;protocol=https;branch=master \
"
SRCREV = "491450db7917c198360b923e93ae899c3445c201"

PR = "r0"

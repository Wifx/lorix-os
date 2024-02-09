require chirpstack-concentratord-v4.inc


SRC_URI += " \
    git://github.com/brocaar/chirpstack-concentratord.git;protocol=https;branch=master \
"
SRCREV = "d716f2c7a9deff6334b14be51f81f90ea643b78e"

PR = "r0"

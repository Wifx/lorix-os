FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://0001-Changed-default-interval-time-to-4s-to-decrease-usel.patch"

# The SAMA5D4 watchdog has a maximum timeout value of 16 seconds, the default 60 seconds is too high.
EXTRA_OECONF_append = " --with-timermargin=16 "
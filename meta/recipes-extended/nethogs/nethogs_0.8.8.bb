SUMMARY = "Net top tool grouping bandwidth by process"
DESCRIPTION = "Nethogs is a small 'net top' tool that displays network \
bandwidth usage per process. Unlike most tools which group traffic by protocol \
or subnet, nethogs groups bandwidth by the specific process ID (PID),  making \
it easy to identify which application is consuming network resources. \
It provides a text-based interface using ncurses and relies on libpcap for \
capturing network traffic."
HOMEPAGE = "https://github.com/raboof/nethogs"

LICENSE = "GPL-2.0-or-later"
LIC_FILES_CHKSUM = " \
    file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263 \
"

DEPENDS = "ncurses libpcap"

inherit meson pkgconfig

# repo available at https://github.com/raboof/nethogs.git
SRCREV = "632a78846eb3cc3259dc45c59a47fa9c293a2831"
SRC_URI = "git://github.com/raboof/nethogs.git;protocol=https;branch=main"

S = "${WORKDIR}/git"

do_install:append() {
    # delete problematic library files
    rm -f ${D}${libdir}/liblibnethogs.so*
}

FILES:${PN} = "${bindir}/nethogs"
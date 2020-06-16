#
# Copyright (C) 2019 Wifx Sàrl
#  Heavilly based on the standard Poky packagegroup-os-full-cmdline.bb recipe
#  Copyright (C) 2010 Intel Corporation
#

SUMMARY = "Standard full-featured Linux system for the Wifx product family"
DESCRIPTION = "Package group bringing in packages needed for a more traditional full-featured Linux system for the Wifx product family"
PR = "r0"

inherit packagegroup

PACKAGES = "\
    packagegroup-os-full-cmdline \
    packagegroup-os-full-cmdline-libs \
    packagegroup-os-full-cmdline-utils \
    packagegroup-os-full-cmdline-extended \
    packagegroup-os-full-cmdline-dev-utils \
    packagegroup-os-full-cmdline-multiuser \
    packagegroup-os-full-cmdline-initscripts \
    packagegroup-os-full-cmdline-sys-services \
    "

python __anonymous () {
    # For backwards compatibility after rename
    namemap = {}
    namemap["packagegroup-os-full-cmdline"] = "packagegroup-os-basic"
    namemap["packagegroup-os-full-cmdline-libs"] = "packagegroup-os-basic-libs"
    namemap["packagegroup-os-full-cmdline-utils"] = "packagegroup-os-basic-utils"
    namemap["packagegroup-os-full-cmdline-extended"] = "packagegroup-os-basic-extended"
    namemap["packagegroup-os-full-cmdline-dev-utils"] = "packagegroup-os-dev-utils"
    namemap["packagegroup-os-full-cmdline-multiuser"] = "packagegroup-os-multiuser"
    namemap["packagegroup-os-full-cmdline-initscripts"] = "packagegroup-os-initscripts"
    namemap["packagegroup-os-full-cmdline-sys-services"] = "packagegroup-os-sys-services"

    packages = d.getVar("PACKAGES").split()
    for pkg in packages:
        if pkg.endswith('-dev'):
            mapped = namemap.get(pkg[:-4], None)
            if mapped:
                mapped += '-dev'
        elif pkg.endswith('-dbg'):
            mapped = namemap.get(pkg[:-4], None)
            if mapped:
                mapped += '-dbg'
        else:
            mapped = namemap.get(pkg, None)

        if mapped:
            oldtaskname = mapped.replace("packagegroup-os", "task-core")
            mapstr = " %s %s" % (mapped, oldtaskname)
            d.appendVar("RPROVIDES_%s" % pkg, mapstr)
            d.appendVar("RREPLACES_%s" % pkg, mapstr)
            d.appendVar("RCONFLICTS_%s" % pkg, mapstr)
}

RDEPENDS_packagegroup-os-full-cmdline = "\
    packagegroup-os-full-cmdline-utils \
    packagegroup-os-full-cmdline-extended \
    packagegroup-os-full-cmdline-multiuser \
    packagegroup-os-full-cmdline-initscripts \
    packagegroup-os-full-cmdline-sys-services \
    "

RDEPENDS_packagegroup-os-full-cmdline-libs = "\
    glib-2.0 \
    "

RDEPENDS_packagegroup-os-full-cmdline-utils = "\
    bash \
    e2fsprogs \
    findutils \
    gawk \
    grep \
    makedevs \
    mktemp \
    net-tools \
    ethtool \
    phytool \
    procps \
    psmisc \
    sed \
    tar \
    time \
    util-linux \
    zlib \
    tree \
    "

RDEPENDS_packagegroup-os-full-cmdline-extended = "\
    iproute2 \
    iputils \
    iptables \
    module-init-tools \
    nano \
    openssl \
    wget \
    "

RDEPENDS_packagegroup-os-full-cmdline-dev-utils = "\
    diffutils \
    elfutils \
    nfs-utils \
    catchsegv \
    ltrace \
    strace \
    "

RRECOMMENDS_packagegroup-os-full-cmdline-dev-utils = "\
    valgrind \
    "

VIRTUAL-RUNTIME_initscripts ?= "initscripts"
VIRTUAL-RUNTIME_init_manager ?= "sysvinit"
VIRTUAL-RUNTIME_login_manager ?= "busybox"
VIRTUAL-RUNTIME_syslog ?= "sysklogd"
RDEPENDS_packagegroup-os-full-cmdline-initscripts = "\
    ${VIRTUAL-RUNTIME_initscripts} \
    ${VIRTUAL-RUNTIME_init_manager} \
    ${VIRTUAL-RUNTIME_login_manager} \
    ${VIRTUAL-RUNTIME_syslog} \
    "

RDEPENDS_packagegroup-os-full-cmdline-multiuser = "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'pam', 'libuser', '', d)} \
    shadow \
    sudo \
    "

RDEPENDS_packagegroup-os-full-cmdline-sys-services = "\
    at \
    bzip2 \
    cronie \
    dbus \
    less \
    logrotate \
    tzdata \
    "

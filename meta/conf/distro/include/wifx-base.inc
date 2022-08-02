# Code based on poky distro with VERSION related variables management removed
DISTRO_VERSION[vardepsexclude] = "DATE"
SDK_VERSION[vardepsexclude] = "DATE"

# Override these in poky based distros
POKY_DEFAULT_DISTRO_FEATURES = "largefile opengl ptest multiarch wayland vulkan"
POKY_DEFAULT_EXTRA_RDEPENDS = "packagegroup-core-boot"
POKY_DEFAULT_EXTRA_RRECOMMENDS = "kernel-module-af-packet"

DISTRO_FEATURES ?= "${DISTRO_FEATURES_DEFAULT} ${DISTRO_FEATURES_LIBC} ${POKY_DEFAULT_DISTRO_FEATURES}"

PREFERRED_VERSION_openssl ?= "1.1.%"
PREFERRED_VERSION_openssl-native ?= "1.1.%"
PREFERRED_VERSION_nativesdk-openssl ?= "1.1.%"

SDK_NAME = "${DISTRO}-${TCLIBC}-${SDKMACHINE}-${IMAGE_BASENAME}-${TUNE_PKGARCH}-${MACHINE}"
SDKPATH = "/opt/${DISTRO}/${SDK_VERSION}"

DISTRO_EXTRA_DEPENDS ??= ""
DISTRO_EXTRA_RDEPENDS += " ${POKY_DEFAULT_EXTRA_RDEPENDS}"
DISTRO_EXTRA_RRECOMMENDS += " ${POKY_DEFAULT_EXTRA_RRECOMMENDS}"

POKYQEMUDEPS = "${@bb.utils.contains("INCOMPATIBLE_LICENSE", "GPL-3.0", "", "packagegroup-core-device-devel",d)}"
DISTRO_EXTRA_RDEPENDS_append_qemuarm = " ${POKYQEMUDEPS}"
DISTRO_EXTRA_RDEPENDS_append_qemuarm64 = " ${POKYQEMUDEPS}"
DISTRO_EXTRA_RDEPENDS_append_qemumips = " ${POKYQEMUDEPS}"
DISTRO_EXTRA_RDEPENDS_append_qemuppc = " ${POKYQEMUDEPS}"
DISTRO_EXTRA_RDEPENDS_append_qemux86 = " ${POKYQEMUDEPS}"
DISTRO_EXTRA_RDEPENDS_append_qemux86-64 = " ${POKYQEMUDEPS}"

TCLIBCAPPEND = ""

QEMU_TARGETS ?= "arm aarch64 i386 mips mipsel mips64 mips64el nios2 ppc x86_64"
# Other QEMU_TARGETS "sh4"

PREMIRRORS ??= "\
bzr://.*/.*   http://downloads.yoctoproject.org/mirror/sources/ \n \
cvs://.*/.*   http://downloads.yoctoproject.org/mirror/sources/ \n \
git://.*/.*   http://downloads.yoctoproject.org/mirror/sources/ \n \
gitsm://.*/.* http://downloads.yoctoproject.org/mirror/sources/ \n \
hg://.*/.*    http://downloads.yoctoproject.org/mirror/sources/ \n \
osc://.*/.*   http://downloads.yoctoproject.org/mirror/sources/ \n \
p4://.*/.*    http://downloads.yoctoproject.org/mirror/sources/ \n \
svn://.*/.*   http://downloads.yoctoproject.org/mirror/sources/ \n"

MIRRORS =+ "\
ftp://.*/.*      http://downloads.yoctoproject.org/mirror/sources/ \n \
http://.*/.*     http://downloads.yoctoproject.org/mirror/sources/ \n \
https://.*/.*    http://downloads.yoctoproject.org/mirror/sources/ \n"

# The CONNECTIVITY_CHECK_URI's are used to test whether we can succesfully
# fetch from the network (and warn you if not). To disable the test set
# the variable to be empty.
# Git example url: git://git.yoctoproject.org/yocto-firewall-test;protocol=git;rev=master
CONNECTIVITY_CHECK_URIS ?= "https://www.example.com/"

SANITY_TESTED_DISTROS ?= " \
            poky-2.7 \n \
            poky-3.0 \n \
            poky-3.1 \n \
            ubuntu-16.04 \n \
            ubuntu-18.04 \n \
            ubuntu-19.04 \n \
            ubuntu-20.04 \n \
            fedora-30 \n \
            fedora-31 \n \
            fedora-32 \n \
            fedora-33 \n \
            fedora-34 \n \
            fedora-35 \n \
            centos-7 \n \
            centos-8 \n \
            debian-8 \n \
            debian-9 \n \
            debian-10 \n \
            debian-11 \n \
            opensuseleap-15.1 \n \
            opensuseleap-15.2 \n \
            opensuseleap-15.3 \n \
            almalinux-8.5 \n \
            "

# add poky sanity bbclass
INHERIT += "poky-sanity"

# QA check settings - a little stricter than the OE-Core defaults
WARN_TO_ERROR_QA = "already-stripped compile-host-path install-host-path \
                    installed-vs-shipped ldflags pn-overrides rpaths staticdev \
                    unknown-configure-option useless-rpaths"
WARN_QA_remove = "${WARN_TO_ERROR_QA}"
ERROR_QA_append = " ${WARN_TO_ERROR_QA}"

require conf/distro/include/poky-world-exclude.inc
require conf/distro/include/no-static-libs.inc
require conf/distro/include/yocto-uninative.inc
require conf/distro/include/security_flags.inc
INHERIT += "uninative"

INHERIT += "reproducible_build"

BB_SIGNATURE_HANDLER ?= "OEEquivHash"
BB_HASHSERVE ??= "auto"

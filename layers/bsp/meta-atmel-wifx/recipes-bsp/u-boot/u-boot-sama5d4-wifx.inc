DESCRIPTION = "U-Boot - the Universal Boot Loader"
HOMEPAGE = "http://www.denx.de/wiki/U-Boot/WebHome"
SECTION = "bootloaders"
PROVIDES = "virtual/bootloader"

inherit uboot-config deploy

#EXTRA_OEMAKE = 'CROSS_COMPILE=${TARGET_PREFIX} CC="${TARGET_PREFIX}gcc ${TOOLCHAIN_OPTIONS}" HOSTCC="${BUILD_CC} ${BUILD_CFLAGS} ${BUILD_LDFLAGS}"'

EXTRA_OEMAKE = 'CROSS_COMPILE=${TARGET_PREFIX} CC="${TARGET_PREFIX}gcc ${TOOLCHAIN_OPTIONS}" V=1'
EXTRA_OEMAKE += 'HOSTCC="${BUILD_CC} ${BUILD_CFLAGS} ${BUILD_LDFLAGS}"'
#EXTRA_OEMAKE += 'PYTHON=nativepython STAGING_INCDIR=${STAGING_INCDIR_NATIVE} STAGING_LIBDIR=${STAGING_LIBDIR_NATIVE}'

DEPENDS += "u-boot-mkenvimage-native dtc-native bc-native"

# Allow setting an additional version string that will be picked up by the
# u-boot build system and appended to the u-boot version.  If the .scmversion
# file already exists it will not be overwritten.
UBOOT_LOCALVERSION ?= ""

# Some versions of u-boot use .bin and others use .img.  By default use .bin
# but enable individual recipes to change this value.
UBOOT_SUFFIX ?= "bin"
UBOOT_IMAGE ?= "u-boot-${MACHINE}-${PV}-${PR}.${UBOOT_SUFFIX}"
UBOOT_BINARY ?= "u-boot.${UBOOT_SUFFIX}"
UBOOT_SYMLINK ?= "u-boot-${MACHINE}.${UBOOT_SUFFIX}"
UBOOT_MAKE_TARGET ?= "all"

# Some versions of u-boot build an SPL (Second Program Loader) image that
# should be packaged along with the u-boot binary as well as placed in the
# deploy directory.  For those versions they can set the following variables
# to allow packaging the SPL.
SPL_BINARY ?= ""
SPL_IMAGE ?= "${SPL_BINARY}-${MACHINE}-${PV}-${PR}"
SPL_SYMLINK ?= "${SPL_BINARY}-${MACHINE}"

# Additional environment variables or a script can be installed alongside
# u-boot to be used automatically on boot.
UBOOT_ENV_SOURCE_SUFFIX ?= "txt"
UBOOT_ENV_BINARY_SUFFIX ?= "bin"
UBOOT_ENV ?= ""
UBOOT_ENV_SOURCE ?= "${UBOOT_ENV}.${UBOOT_ENV_SOURCE_SUFFIX}"
UBOOT_ENV_IMAGE ?= "u-boot-env-${UBOOT_ENV}-${MACHINE}-${PV}-${PR}"
UBOOT_ENV_BINARY ?= "u-boot-env.${UBOOT_ENV}.${UBOOT_ENV_BINARY_SUFFIX}"
UBOOT_ENV_BINARY_SIZE ?= "0x20000"
UBOOT_ENV_SYMLINK ?= "u-boot-env-${UBOOT_ENV}-${MACHINE}"

# Env directory is where target variant files are stored
UBOOT_ENV_DIR = "${WORKDIR}/target_env"
UBOOT_ENV_BASE_NAME = "${MACHINE}${@bb.utils.contains('DISTRO_FEATURES', 'mender', '-mender', '', d)}"
UBOOT_ENV_BASE_FILE = "${UBOOT_ENV_DIR}/${UBOOT_ENV_BASE_NAME}.env"


ENV_BIN_DIR = "${WORKDIR}/target_env_bin"

# Env deploy dir is the name of directory where binary envs will be deployed
ENV_DEPLOY_DIR="u-boot-envs"

# Env deploy src dir is the name of directory where txt envs will be deployed
ENV_SRC_DEPLOY_DIR="u-boot-envs-src"

ENV_IMAGE = "${S}/env.bin"

do_compile() {
	if [ "${@bb.utils.contains('DISTRO_FEATURES', 'ld-is-gold', 'ld-is-gold', '', d)}" = "ld-is-gold" ] ; then
		sed -i 's/$(CROSS_COMPILE)ld$/$(CROSS_COMPILE)ld.bfd/g' config.mk
	fi

	unset LDFLAGS
	unset CFLAGS
	unset CPPFLAGS

	if [ ! -e ${B}/.scmversion -a ! -e ${S}/.scmversion ]
	then
		echo ${UBOOT_LOCALVERSION} > ${B}/.scmversion
		echo ${UBOOT_LOCALVERSION} > ${S}/.scmversion
	fi

	oe_runmake ${UBOOT_MACHINE}
	oe_runmake ${UBOOT_MAKE_TARGET}
}

python do_environment_mkimage() {
    import subprocess
    import shutil
    import os.path

    # test if env image need to be created
    uboot_env = d.getVar('UBOOT_ENV',True)
    if not uboot_env.strip():
        return 0

    # workdir
    workdir = d.getVar('WORKDIR',True)

    source_filename = d.getVar('UBOOT_ENV_SOURCE',True)
    source_file = os.path.join(workdir, source_filename)
    dest_filename = d.getVar('UBOOT_ENV_BINARY',True)
    dest_file = os.path.join(workdir, dest_filename)

    # test if environment source file is available in working directory
    if not os.path.isfile(source_file):
        bb.fatal('File "' + source_filename + '" is missing from WORKDIR, is it included in SRC_URI ?')

    # test if environment binary file already exists
    if os.path.isfile(dest_file):
        # delete it
        try:
            os.unlink(dest_file)
        except OSError: pass

    # build output file path with ext
    #target_file = d.getVar('ENV_BASE_NAME',True) + '.bin'
    #target_bin = os.path.join(env_bin_dir, target_file)
    print('Building binary environment ', dest_filename, ' in ', workdir)
    # generated mkenvimage tool command line
    cmd_mkimg ='cat %s | grep -v -E "^$|^\#" |' \
            ' mkenvimage -s %s -r -o %s -' \
            % ( source_file, d.getVar("UBOOT_ENV_BINARY_SIZE",True), dest_file)

    print(cmd_mkimg)
    # execute shell command
    ret = subprocess.call(cmd_mkimg, shell=True)
    if ret: return ret
    return 0
}
addtask environment_mkimage after do_compile before do_deploy

do_install() {
    install -d ${D}/boot
    install ${S}/${UBOOT_BINARY} ${D}/boot/${UBOOT_IMAGE}
    ln -sf ${UBOOT_IMAGE} ${D}/boot/${UBOOT_BINARY}

    if [ -e ${WORKDIR}/fw_env.config ] ; then
        install -d ${D}${sysconfdir}
        install -m 644 ${WORKDIR}/${UBOOT_FW_ENV_FILE} ${D}${sysconfdir}/fw_env.config
    fi

    if [ "x${SPL_BINARY}" != "x" ]
    then
        install ${S}/${SPL_BINARY} ${D}/boot/${SPL_IMAGE}
        ln -sf ${SPL_IMAGE} ${D}/boot/${SPL_BINARY}
    fi
}

do_deploy() {
    install -d ${DEPLOYDIR}
    install ${S}/${UBOOT_BINARY} ${DEPLOYDIR}/${UBOOT_IMAGE}

    cd ${DEPLOYDIR}
    rm -f ${UBOOT_BINARY} ${UBOOT_SYMLINK}
    ln -sf ${UBOOT_IMAGE} ${UBOOT_SYMLINK}
    ln -sf ${UBOOT_IMAGE} ${UBOOT_BINARY}

    if [ "x${SPL_BINARY}" != "x" ]
    then
        install ${S}/${SPL_BINARY} ${DEPLOYDIR}/${SPL_IMAGE}
        rm -f ${DEPLOYDIR}/${SPL_BINARY} ${DEPLOYDIR}/${SPL_SYMLINK}
        ln -sf ${SPL_IMAGE} ${DEPLOYDIR}/${SPL_BINARY}
        ln -sf ${SPL_IMAGE} ${DEPLOYDIR}/${SPL_SYMLINK}
    fi

    if [ "${@bb.utils.contains('MACHINE_FEATURES', 'sdimg', 'sdimg', '', d)}" = "sdimg" ] ; then
		echo "Generating SD img"
    else
        echo "Generating NAND img"
	fi

    # deploy  binary U-boot environments
    if [ -n "${UBOOT_ENV}" ]
    then
        echo "Deploying U-boot environment source file in ${DEPLOYDIR}"
        install -m 644 ${WORKDIR}/${UBOOT_ENV_SOURCE} "${DEPLOYDIR}/${UBOOT_ENV_IMAGE}.${UBOOT_ENV_SOURCE_SUFFIX}"
        ln -sf ${UBOOT_ENV_IMAGE}.${UBOOT_ENV_SOURCE_SUFFIX} ${DEPLOYDIR}/${UBOOT_ENV_SYMLINK}.${UBOOT_ENV_SOURCE_SUFFIX}
        ln -sf ${UBOOT_ENV_IMAGE}.${UBOOT_ENV_SOURCE_SUFFIX} ${DEPLOYDIR}/u-boot-env.${UBOOT_ENV_SOURCE_SUFFIX}

        echo "Deploying U-boot environment binary file in ${DEPLOYDIR}"
        install -m 644 ${WORKDIR}/${UBOOT_ENV_BINARY} "${DEPLOYDIR}/${UBOOT_ENV_IMAGE}.${UBOOT_ENV_BINARY_SUFFIX}"
        rm -f ${DEPLOYDIR}/${UBOOT_ENV_BINARY} ${DEPLOYDIR}/${UBOOT_ENV_SYMLINK}.${UBOOT_ENV_BINARY_SUFFIX}
        ln -sf ${UBOOT_ENV_IMAGE}.${UBOOT_ENV_BINARY_SUFFIX} ${DEPLOYDIR}/${UBOOT_ENV_SYMLINK}.${UBOOT_ENV_BINARY_SUFFIX}
        ln -sf ${UBOOT_ENV_IMAGE}.${UBOOT_ENV_BINARY_SUFFIX} ${DEPLOYDIR}/${UBOOT_ENV_BINARY}
        ln -sf ${UBOOT_ENV_IMAGE}.${UBOOT_ENV_BINARY_SUFFIX} ${DEPLOYDIR}/u-boot-env.${UBOOT_ENV_BINARY_SUFFIX}
    fi
}

FILES_${PN} = "/boot ${sysconfdir}"

addtask deploy after do_compile before do_build

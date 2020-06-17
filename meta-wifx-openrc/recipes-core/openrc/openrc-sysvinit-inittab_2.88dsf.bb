SUMMARY = "Inittab configuration for SysVinit optimized for OpenRC"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

PR = "r0"


SRC_URI = " \
    file://inittab \
    file://getty.initd \
    file://getty.confd \
"
inherit openrc-native

S = "${WORKDIR}"

INHIBIT_DEFAULT_DEPS = "1"
do_compile[noexec] = "1"

REDPENDS_${PN} += "sed awk"

do_install() {
    install -d ${D}${sysconfdir}
    install -m 0644 ${WORKDIR}/inittab ${D}${sysconfdir}/inittab

    # Manage serial console
    # ================================
    # Install base getty conf file
    openrc_install_config ${WORKDIR}/getty.confd

    # Install base getty init file
    openrc_install_script ${WORKDIR}/getty.initd

    set -x

    echo "" >> ${D}${sysconfdir}/inittab

    if [ "${USE_VT}" = "1" ]; then
        cat <<EOF >>${D}${sysconfdir}/inittab
# ${base_sbindir}/getty invocations for the runlevels.
#
# The "id" field MUST be the same as the last
# characters of the device (after "tty").
#
# Format:
#  <id>:<runlevels>:<action>:<process>
#

EOF
        for n in ${SYSVINIT_ENABLED_GETTYS}
        do
            echo "$n:12345:respawn:${base_sbindir}/getty 38400 tty$n" >> ${D}${sysconfdir}/inittab
        done
        echo "" >> ${D}${sysconfdir}/inittab
    fi

    tmp="${SERIAL_CONSOLES}"
    for i in $tmp
    do
        j=`echo ${i} | sed s/\;/\ /g`
        baud=`echo ${j} | awk '{print $1}'`
        port=`echo ${j} | awk '{print $2}'`

        name="getty.$port"
        if [ ! -f ${D}${OPENRC_CONFDIR}/$name ]; then
            install -m 644 ${WORKDIR}/getty.confd ${D}${OPENRC_CONFDIR}/$name
        fi
        if [ ! -f ${D}${OPENRC_INITDIR}/$name ] && [ ! -e ${D}${OPENRC_INITDIR}/$name ]; then
            ln -snf ${OPENRC_INITDIR}/getty ${D}${OPENRC_INITDIR}/$name
        fi
        openrc_add_to_default_runlevel ${D} $name

        sed -i \
            -e 's|baud="115200"|baud="'"$baud"'"|' \
            ${D}${OPENRC_CONFDIR}/$name
    done

}

pkg_postinst_${PN} () {
# run this on host and on target
if [ "${SERIAL_CONSOLES_CHECK}" = "" ]; then
       exit 0
fi
}

pkg_postinst_ontarget_${PN} () {
# run this on the target
if [ -e /proc/consoles ]; then
    tmp="${SERIAL_CONSOLES_CHECK}"
    for i in $tmp
    do
        j=`echo ${i} | sed -e s/^.*\;//g -e s/\:.*//g`
        k=`echo ${i} | sed s/^.*\://g`
        if [ -z "`grep ${j} /proc/consoles`" ]; then
            if [ -z "${k}" ] || [ -z "`grep ${k} /proc/consoles`" ] || [ ! -e /dev/${j} ]; then
                sed -i -e /^.*${j}\ /d -e /^.*${j}$/d /etc/inittab
            fi
        fi
    done
    kill -HUP 1
else
    exit 1
fi
}

# USE_VT and SERIAL_CONSOLES are generally defined by the MACHINE .conf.
# Set PACKAGE_ARCH appropriately.
PACKAGE_ARCH = "${MACHINE_ARCH}"

CONFFILES_${PN} = "${sysconfdir}/inittab"

USE_VT ?= "1"
SYSVINIT_ENABLED_GETTYS ?= "1"

RCONFLICTS_${PN} = "busybox-inittab"


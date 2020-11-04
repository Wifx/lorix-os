OPENRC_CONFDIR ?= "${sysconfdir}/conf.d"
OPENRC_INITDIR ?= "${sysconfdir}/openrc.d"

RDEPENDS_${PN}_append = " ${@bb.utils.contains('DISTRO_FEATURES','openrc','openrc','',d)}"

def use_openrc(d):
    if bb.utils.contains('DISTRO_FEATURES', 'openrc', True, False, d):
        return 'true'
    return 'false'

openrc_install_script() {
    local svc
    local path

    [ ! -d ${D}${OPENRC_INITDIR} ] && install -d ${D}${OPENRC_INITDIR}

    for path in $*; do
        svc=$(basename ${path%\.initd})
        install -m 755 ${path} ${D}${OPENRC_INITDIR}/${svc}
    done
}

openrc_install_config() {
    local svc
    local path

    [ ! -d ${D}${OPENRC_CONFDIR} ] && install -d ${D}${OPENRC_CONFDIR}

    for path in $*; do
        svc=$(basename ${path%\.confd})
        install -m 644 ${path} ${D}${OPENRC_CONFDIR}/${svc}
    done
}

_openrc_add_to_runlevel() {
    local runlevel=$1
    local destdir=$2
    local svc

    if ! echo ${destdir} | grep -q "^/"; then
        bbfatal "Destination '${destdir}' does not look like a path"
    fi

    shift
    shift

    [ ! -d ${destdir}${sysconfdir}/runlevels/${runlevel} ] \
        && install -d ${destdir}${sysconfdir}/runlevels/${runlevel}

    for svc in $*; do
        ln -snf ${OPENRC_INITDIR}/${svc} ${destdir}${sysconfdir}/runlevels/${runlevel}
    done
}

# Add services to the sysinit runlevel
#
# @param    - Filesystem root
# @params   - Services to add to sysinit runlevel
openrc_add_to_sysinit_runlevel() {
    _openrc_add_to_runlevel sysinit $*
}


# Add services to the default runlevel
#
# @param    - Filesystem root
# @params   - Services to add to default runlevel
openrc_add_to_default_runlevel() {
    _openrc_add_to_runlevel default $*
}

# Add services to the boot runlevel
#
# @param    - Filesystem root
# @params   - Services to add to boot runlevel
openrc_add_to_boot_runlevel() {
    _openrc_add_to_runlevel boot $*
}

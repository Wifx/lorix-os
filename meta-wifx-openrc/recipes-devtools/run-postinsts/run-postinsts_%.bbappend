FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
    file://run-postinsts.initd \
    file://run-postinsts.confd \
"

inherit openrc

OPENRC_SERVICE_${PN} = "run-postinsts"
OPENRC_RUNLEVEL_run-postinsts = "sysinit"

remove_path_relative() {
    local oldpath=$(pwd)
    local currentpath
    local startpath=$1
    local endpath=$2

    cd "$startpath"
    while true
    do
        currentpath=$(pwd)
        if [ "$endpath" = "$currentpath" ]; then
            break
        fi

        cd ..
        rm -rf "$currentpath"
    done
    cd $oldpath
}

do_install_append() {
    # Remove standard run-postinsts script executable
    remove_path_relative ${D}${sbindir} ${D}

    # Install OpenRC conf script
    openrc_install_config ${WORKDIR}/run-postinsts.confd

    # Install OpenRC script
    openrc_install_script ${WORKDIR}/run-postinsts.initd

    sed -i -e 's:#SYSCONFDIR#:${sysconfdir}:g' \
            -e 's:#SBINDIR#:${sbindir}:g' \
            -e 's:#BASE_BINDIR#:${base_bindir}:g' \
            -e 's:#LOCALSTATEDIR#:${localstatedir}:g' \
            ${D}${OPENRC_INITDIR}/run-postinsts
}

# Copyright (c) 2019-2020, Wifx Sàrl <info@wifx.net>
# All rights reserved.
# Based on work of jsbronder, meta-openrc (https://github.com/jsbronder/meta-openrc)

OPENRC_PACKAGES ?= "${PN}"
OPENRC_PACKAGES_class-native ?= ""
OPENRC_PACKAGES_class-nativesdk ?= ""

inherit openrc-native

# This class will be included in any recipe that supports openrc init scripts,
# even if openrc is not in DISTRO_FEATURES.  As such don't make any changes
# directly but check the DISTRO_FEATURES first.
python __anonymous() {
    # If the distro features have openrc, inhibit update-rcd
    # from doing any work so that pure-openrc images don't have redundant init
    # files.
    if use_openrc(d):
        d.setVar("INHIBIT_UPDATERCD_BBCLASS", "1")
}

openrc_postinst() {
${OPENRC_NAMES_VAR}
${OPENRC_RUNLEVELS_VAR}
for service in ${OPENRC_SERVICE_ESCAPED}; do
    eval name=\$OPENRC_NAME_$service
    eval runlevel=\$OPENRC_RUNLEVEL_$service
    if [ -n "$D" ]; then
        if [ -e "$D${OPENRC_INITDIR}/$name" ]; then
            [ ! -d "$D${sysconfdir}/runlevels/$runlevel" ] && install -m 0755 -d "$D${sysconfdir}/runlevels/$runlevel"

            ln -snf "${OPENRC_INITDIR}/$name" "$D${sysconfdir}/runlevels/$runlevel/$name"
        fi
    else
        if [ -e "${OPENRC_INITDIR}/$name" ]; then
            rc-update -qq add $name $runlevel || :
        fi
    fi
done
}

openrc_prerm() {
if [ -z "$D" ]; then
    ${OPENRC_NAMES_VAR}
    ${OPENRC_RUNLEVELS_VAR}
    for service in ${OPENRC_SERVICE_ESCAPED}; do
        eval name=\$OPENRC_NAME_$service
        eval runlevel=\$OPENRC_RUNLEVEL_$service
        if type rc-service >/dev/null 2>/dev/null; then
            rc-service --ifexists --ifstarted --ifinactive $name stop
        fi
        if type rc-update >/dev/null 2>/dev/null; then
            rc-update -qq del $name $runlevel || :
        fi
    done
fi
}

PACKAGESPLITFUNCS_prepend = "${@bb.utils.contains('DISTRO_FEATURES', 'openrc', 'openrc_populate_packages ', '', d)}"
PACKAGESPLITFUNCS_remove_class-nativesdk = "openrc_populate_packages "

openrc_populate_packages[vardeps] += "openrc_prerm openrc_postrm openrc_preinst openrc_postinst OPENRC_PACKAGES"
openrc_populate_packages[vardepsexclude] += "OVERRIDES"
# Add openrc_populate_packages variables dependencies (OPENRC_PACKAGES, OPENRC_SERVICE_* and OPENRC_RUNLEVEL_*)
python __anonymous() {
    openrc_packages = d.getVar('OPENRC_PACKAGES')

    # scan for all in OPENRC_SERVICE[]
    for pkg_openrc in openrc_packages.split():
        d.appendVar('RDEPENDS_' + pkg_openrc, " openrc")
        d.appendVarFlag('openrc_populate_packages', 'vardeps', ' OPENRC_SERVICE_' + pkg_openrc)
        openrc_services = d.getVar('OPENRC_SERVICE_' + pkg_openrc)
        if openrc_services:
            for service in openrc_services.split():
                d.appendVarFlag('openrc_populate_packages', 'vardeps', ' OPENRC_RUNLEVEL_' + service)
}

python openrc_populate_packages() {
    import shlex

    if not use_openrc(d):
        return

    def get_package_var(d, var, pkg):
        val = (d.getVar('%s_%s' % (var, pkg)) or "").strip()
        if val == "":
            val = (d.getVar(var) or "").strip()
        return val

    def openrc_check_package(pkg_openrc):
        packages = d.getVar('PACKAGES')
        if not pkg_openrc in packages.split():
            bb.error('%s defined in OPENRC_PACKAGES does not appear in package list' % pkg_openrc)

    def openrc_check_runlevel(pkg_service):
        runlevel = d.getVar('OPENRC_RUNLEVEL_' + pkg_service)
        if not runlevel:
            bb.warn("OpenRC script '%s' runlevel not defined in OPENRC_RUNLEVEL_%s, assuming runlevel 'default'" % (pkg_service, pkg_service))
            runlevel = 'default'
        else:
            runlevel = runlevel.strip()
        d.setVar('OPENRC_RUNLEVEL_' + pkg_service, runlevel)
        runlevels = ['sysinit', 'boot', 'default', 'nonetwork', 'shutdown']
        if runlevel not in runlevels:
            bb.fatal("OpenRC script '%s' runlevel '%s' is not valid (can be one of '%s')" % (pkg_service, runlevel, "', '".join(runlevels)))
        return runlevel

    def openrc_generate_package_scripts(pkg):
        paths_escaped = ' '.join(shlex.quote(s) for s in d.getVar('OPENRC_SERVICE_' + pkg).split())
        d.setVar('OPENRC_SERVICE_ESCAPED_' + pkg, paths_escaped.replace('-', '_'))

        openrc_names_var = ""
        openrc_runlevels_var = ""
        for service in paths_escaped.split():
            runlevel = openrc_check_runlevel(service)

            # Add script name to names variable
            if openrc_names_var:
                openrc_names_var += "; "
            openrc_names_var += 'OPENRC_NAME_' + service.replace('-', '_') + '=' + service

            # Add script runlevel to runlevels variable
            if openrc_runlevels_var:
                openrc_runlevels_var += "; "
            openrc_runlevels_var += 'OPENRC_RUNLEVEL_' + service.replace('-', '_') + '=' + runlevel

        # Prepare names and runlevels variables for post install scripts
        d.setVar('OPENRC_NAMES_VAR_%s' % pkg, openrc_names_var)
        d.setVar('OPENRC_RUNLEVELS_VAR_%s' % pkg, openrc_runlevels_var)

        # Add pkg to the overrides so that it finds the OPENRC_SERVICE_pkg
        # variable.
        localdata = d.createCopy()
        localdata.prependVar("OVERRIDES", pkg + ":")

        postinst = d.getVar('pkg_postinst_%s' % pkg)
        if not postinst:
            postinst = '#!/bin/sh\n'
        postinst += localdata.getVar('openrc_postinst')
        d.setVar('pkg_postinst_%s' % pkg, postinst)

        prerm = d.getVar('pkg_prerm_%s' % pkg)
        if not prerm:
            prerm = '#!/bin/sh\n'
        prerm += localdata.getVar('openrc_prerm')
        d.setVar('pkg_prerm_%s' % pkg, prerm)

    # Add files to FILES_* if existent and not already done
    def openrc_append_file(pkg_openrc, file_append):
        appended = False
        if os.path.exists(oe.path.join(d.getVar("D"), file_append)):
            var_name = "FILES_" + pkg_openrc
            files = d.getVar(var_name, False) or ""
            if file_append not in files.split():
                d.appendVar(var_name, " " + file_append)
                appended = True
        return appended

    def openrc_check_services():
        # searchpaths is only a path but could be a path array
        searchpaths = [d.getVar("OPENRC_INITDIR"),]
        openrc_packages = d.getVar('OPENRC_PACKAGES')

        # scan for all in OPENRC_SERVICE[]
        for pkg_openrc in openrc_packages.split():
            for service in get_package_var(d, 'OPENRC_SERVICE', pkg_openrc).split():
                path_found = ''
                for path in searchpaths:
                    if os.path.exists(oe.path.join(d.getVar("D"), path, service)):
                        path_found = path
                        break

                if path_found != '':
                    openrc_append_file(pkg_openrc, oe.path.join(path_found, service))
                else:
                    bb.fatal("OpenRC script '%s' defined in OPENRC_SERVICE_%s has not been found, did you forget to install it ?" % (service, pkg_openrc))

     # Run all modifications once when creating package
    if os.path.exists(d.getVar("D")):
        for pkg in d.getVar('OPENRC_PACKAGES').split():
            openrc_check_package(pkg)
            if d.getVar('OPENRC_SERVICE_' + pkg):
                openrc_generate_package_scripts(pkg)
        openrc_check_services()
}

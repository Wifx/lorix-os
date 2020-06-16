inherit wifx-tools

DEPENDS_${PN} += "os-release"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI_FEATURE_MOTD_DYNAMIC = " \
    file://update-motd.d/* \
"
SRC_URI += " \
    file://motd-template \
    ${@bb.utils.contains('DISTRO_FEATURES','motd-dynamic','${SRC_URI_FEATURE_MOTD_DYNAMIC}','',d)} \
    "

def print_release_note(string, version_state, color, color_light):

    string += (" [39mRELEASE NOTE: "+color_light+"This is a \""+color+version_state+color_light+"\" release version\n"
            " Please note that this is NOT considered as a stable\n"
            " and production ready version. Bugs or instabilities\n"
            " may occur and should be reported by e-mail to [39msupport@iot.wifx.net\n"
    )
    return string

def populate_header(template_str, version_str, rev_hash_str, rev_date_str, codename_str, machine_str):
    import datetime

    # Generate a more pretty date
    rev_date = datetime.datetime.strptime(rev_date_str, '%Y-%m-%dT%H:%M:%SZ')
    rev_date_str = rev_date.strftime('%d %B %Y, %H:%M:%S')

    template_str = template_str.replace('@{VERSION}', version_str)
    template_str = template_str.replace('@{HASH}', rev_hash_str)
    template_str = template_str.replace('@{CODENAME}', codename_str)
    template_str = template_str.replace('@{DATE}', rev_date_str)
    template_str = template_str.replace('@{MACHINE}', machine_str)
    return template_str

def populate_release_note(string, version_str, variant_str, audience_str):
    if "-alpha" in version_str:
        string += print_release_note(string, "alpha", "[31m", "[91m")

    if "-beta" in version_str:
        string += print_release_note(string, "beta", "[33m", "[93m")

    if "-rc" in version_str:
        string += print_release_note(string, "release-candidate", "[33m", "[93m")

    if variant_str == 'dev':
        string += (" [39mRELEASE NOTE:[91m development image, should not be used\n"
                " for production[0m\n"
        )

    if audience_str == 'conf':
        string += (" [39mRELEASE NOTE:[91m THIS IS A CONFIDENTIAL BUILD, DO NOT\n"
                " DISTRIBUTE FURTHER[0m\n"
        )

    return string

python do_motd_static() {
    import shutil

    # Retrieve os-release values
    source_shell_param_file(d.expand('${STAGING_DIR_TARGET}${libdir}/os-release'), d)

    # Copy the motd template file to have a clean file on each iteration
    shutil.copy2(d.expand('${WORKDIR}/motd-template'), d.expand('${WORKDIR}/motd'))

    version = d.getVar('DISTRO_VERSION', True)
    rev_hash = d.getVar('WORKSPACE_REV_HASH', True)
    rev_date_str = d.getVar('WORKSPACE_REV_DATE', True)
    codename = d.getVar('VERSION_CODENAME', True)
    variant_id = d.getVar('VARIANT_ID', True)
    audience_id = d.getVar('AUDIENCE_ID', True)

    machine = d.getVar('MACHINE', True)

    # Populate motd file with version, hash and date
    string = open(d.expand('${WORKDIR}/motd'),'r').read()
    string = populate_header(string, version, rev_hash, rev_date_str, codename, machine)
    # Create release note string
    str_tmp = populate_release_note("", version, variant_id, audience_id)
    if str_tmp:
        string += str_tmp
        if not (d.getVar('INHIBIT_DEFAULT_ENDLF', True) == '1'):
            string += "\n"

    f = open(d.expand('${WORKDIR}/motd'),'w')
    f.write(string)
    f.close()
}

python do_motd_dynamic() {
    import shutil

    # Retrieve os-release values
    source_shell_param_file(d.expand('${STAGING_DIR_TARGET}${libdir}/os-release'), d)

    version = d.getVar('DISTRO_VERSION', True)
    rev_hash = d.getVar('WORKSPACE_REV_HASH', True)
    rev_date_str = d.getVar('WORKSPACE_REV_DATE', True)
    codename = d.getVar('VERSION_CODENAME', True)
    variant_id = d.getVar('VARIANT_ID', True)
    audience_id = d.getVar('AUDIENCE_ID', True)
    machine = d.getVar('MACHINE', True)

    # Populate motd header file with version, hash and date with static content
    string = open(d.expand('${WORKDIR}/update-motd.d/static/00-header'),'r').read()
    f = open(d.expand('${WORKDIR}/update-motd.d/static/00-header'),'w')
    f.write(populate_header(string, version, rev_hash, rev_date_str, codename, machine))
    f.close()

    # Populate motd release file with static content
    string = populate_release_note("", version, variant_id, audience_id)
    if string and not (d.getVar('INHIBIT_DEFAULT_ENDLF', True) == '1'):
        string += "\n"
    f = open(d.expand('${WORKDIR}/update-motd.d/static/99-release-notes'),'w')
    f.write(string)
    f.close()
}

python __anonymous() {
    if bb.utils.contains('DISTRO_FEATURES', 'motd-dynamic', True, False, d):
        bb.build.addtask('do_motd_dynamic', 'do_install', 'do_unpack', d)
    else:
        bb.build.addtask('do_motd_static', 'do_install', 'do_unpack', d)

    # We need to reset the files thanks to unpack on each os-release data update
    d.setVarFlag('do_unpack', 'depends', 'os-release:do_populate_sysroot')
}

do_install_append() {
    if ${@bb.utils.contains('DISTRO_FEATURES','motd-dynamic','true','false',d)}; then
        # we remove the standard motd
        rm -rf ${D}${sysconfdir}/motd

        # create dynamic motd
        install -m 0755 -d ${D}${sysconfdir}/update-motd.d
        install -m 0755 -d ${D}${sysconfdir}/update-motd.d/static

        # install dynamic motd generation files
        cd ${WORKDIR}/update-motd.d
        for file in $(find . -maxdepth 1 -type f); do
            install -m 0755 -D ${WORKDIR}/update-motd.d/$file ${D}${sysconfdir}/update-motd.d/$file
        done
        for file in $(find static -maxdepth 1 -type f); do
            install -m 0644 -D ${WORKDIR}/update-motd.d/$file ${D}${sysconfdir}/update-motd.d/$file
        done
    fi


    # install skel files into root home if exists
    if [ -d ${D}${ROOT_HOME} ]; then
        cp -rT ${D}${sysconfdir}/skel ${D}${ROOT_HOME}
    fi
}
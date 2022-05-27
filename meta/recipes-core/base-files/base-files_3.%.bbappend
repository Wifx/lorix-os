inherit wifx-tools

DEPENDS += "os-release"

RDEPENDS_${PN} += "machine-info"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_FEATURE_MOTD_DYNAMIC = " \
    file://update-motd.d/00-header \
    file://update-motd.d/05-product \
    file://update-motd.d/10-sysinfo \
    file://update-motd.d/20-update \
    file://update-motd.d/90-release-notes \
    file://update-motd.d/99-reset-style \
"
SRC_URI += " \
    file://motd-header-template \
    ${@bb.utils.contains('DISTRO_FEATURES','motd-dynamic','${SRC_URI_FEATURE_MOTD_DYNAMIC}','',d)} \
    file://fstab \
"

dirs755_remove = "${localstatedir}/volatile/log"
volatiles_remove = "log"

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
    import os

    # Retrieve os-release values
    source_shell_param_file(d.expand('${STAGING_DIR_TARGET}${libdir}/os-release'), d)

    version = d.getVar('DISTRO_VERSION', True)
    rev_hash = d.getVar('WORKSPACE_REV_HASH', True)
    rev_date_str = d.getVar('WORKSPACE_REV_DATE', True)
    codename = d.getVar('VERSION_CODENAME', True)
    variant_id = d.getVar('VARIANT_ID', True)
    audience_id = d.getVar('AUDIENCE_ID', True)
    machine = d.getVar('MACHINE', True)

    # Read motd header template
    header_template = open(d.expand('${WORKDIR}/motd-header-template'),'r').read()

    static_motd_dir = d.expand('${WORKDIR}/motd-static')
    if not os.path.exists(static_motd_dir):
        os.makedirs(static_motd_dir)

    # Populate motd header file with version, hash and date with static content
    f = open(d.expand('${WORKDIR}/motd-static/00-header'),'w+')
    f.write(populate_header(header_template, version, rev_hash, rev_date_str, codename, machine))
    f.close()

    # Populate motd release file with release note
    release_note = populate_release_note("", version, variant_id, audience_id)
    if release_note and not (d.getVar('INHIBIT_DEFAULT_ENDLF', True) == '1'):
        release_note += "\n"
    f = open(d.expand('${WORKDIR}/motd-static/90-release-notes'),'w+')
    f.write(release_note)
    f.close()

    f = open(d.expand('${WORKDIR}/motd'),'w')
    f.write(open(d.expand('${WORKDIR}/motd-static/00-header'),'r').read())
    f.write(open(d.expand('${WORKDIR}/motd-static/90-release-notes'),'r').read())
    f.close()
}

python __anonymous() {
    bb.build.addtask('do_motd_static', 'do_install', 'do_unpack', d)

    # We need to reset the files thanks to unpack on each os-release data update
    d.setVarFlag('do_unpack', 'depends', 'os-release:do_populate_sysroot')
}

do_install_append() {
    if ${@bb.utils.contains('DISTRO_FEATURES','motd-dynamic','true','false',d)}; then
        # we remove the standard motd
        rm -rf ${D}${sysconfdir}/motd

        install -m 0755 -d ${D}${sysconfdir}/update-motd.d

        # install static motd
        install -m 0755 -d ${D}${sysconfdir}/update-motd.d/static
        for file in $(find ${WORKDIR}/motd-static -maxdepth 1 -type f -execdir echo {} ';'); do
            install -m 0644 -D ${WORKDIR}/motd-static/$file ${D}${sysconfdir}/update-motd.d/static/$file
        done

        # install dynamic motd generation files
        if ${@bb.utils.contains('DISTRO_FEATURES','motd-dynamic','true','false',d)}; then
            for file in $(find ${WORKDIR}/update-motd.d -maxdepth 1 -type f -execdir echo {} ';'); do
                install -m 0755 -D ${WORKDIR}/update-motd.d/$file ${D}${sysconfdir}/update-motd.d/$file
            done
        fi
    fi

    # install volatile log files (mounted to tmpfs by fstab)
    install -d -m 0755 ${D}${localstatedir}/log-volatile
    ln -snf log-volatile ${D}${localstatedir}/log

    # install skel files into root home if exists
    if [ -d ${D}${ROOT_HOME} ]; then
        cp -rT ${D}${sysconfdir}/skel ${D}${ROOT_HOME}
    fi
}
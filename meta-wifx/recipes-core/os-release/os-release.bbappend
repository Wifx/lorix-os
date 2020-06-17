inherit deploy wifx-tools

# Add custom OS fields
OS_RELEASE_FIELDS = " \
    ID \
    ID_LIKE \
    NAME \
    VERSION \
    VERSION_ID \
    VERSION_NORM \
    VERSION_CODENAME \
    PRETTY_NAME \
    WORKSPACE_REV_HASH \
    WORKSPACE_REV_DATE \
    MACHINE \
    VARIANT \
    VARIANT_ID \
    AUDIENCE \
    AUDIENCE_ID \
"

VERSION_CODENAME = "${DISTRO_CODENAME}"
VERSION_NORM = "${DISTRO_VERSION}"
VARIANT = "${@bb.utils.contains('DEVELOPMENT_IMAGE','1','Development','Production',d)}"
VARIANT_ID = "${@bb.utils.contains('DEVELOPMENT_IMAGE','1','dev','prod',d)}"

python () {
    # Generate audience value
    if "-alpha" in d.getVar('DISTRO_VERSION', True) or "-beta" in d.getVar('DISTRO_VERSION', True):
        d.setVar('AUDIENCE', 'CONFIDENTIAL')
        d.setVar('AUDIENCE_ID', 'conf')
    else:
        d.setVar('AUDIENCE', 'Public')
        d.setVar('AUDIENCE_ID', 'pub')
}

#
# Add quotes around values not matching [A-Za-z0-9]*
# Failing to do so will confuse the container engine
#
python do_fix_quotes () {
    import re
    lines = open(d.expand('${B}/os-release'), 'r').readlines()
    with open(d.expand('${B}/os-release'), 'w') as f:
        for line in lines:
            field = line.split('=')[0].strip()
            value = line.split('=')[1].strip()
            match = re.match(r"^[A-Za-z0-9]*$", value)
            match_quoted = re.match(r"^\".*\"$", value)
            if not match and not match_quoted:
                value = '"' + value + '"'
            f.write('{0}={1}\n'.format(field, value))
}
addtask fix_quotes after do_compile before do_install

do_deploy() {
    # Issue #906
    # Make the os-release available in the deploy directory as well so we can
    # include it in the boot partition
    install -m 644 ${D}/etc/os-release ${DEPLOYDIR}/os-release
}
addtask do_deploy before do_package after do_install

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

# We don't want unquoted field in our distro
OS_RELEASE_UNQUOTED_FIELDS = ""

# Extra fields generation
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

do_deploy() {
    # Make the os-release available in the deploy directory as well so we can
    # use it for external image build tools.
    install -m 644 ${D}/etc/os-release ${DEPLOYDIR}/os-release
}
addtask do_deploy before do_package after do_install

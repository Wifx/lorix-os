PACKAGESPLITFUNCS:prepend = "populate_packages_overrides "
populate_packages_overrides[vardeps] += "pkg_postinst_ontarget:${PN}:lorix_one pkg_postinst_ontarget:${PN}:l1"

python populate_packages_overrides() {
    pkg = d.getVar('PN', True)
    machine = d.getVar('MACHINE', True)

    # Helper to get variable with specific override active
    def get_var_with_override(override):
        localdata = d.createCopy()
        # Force overrides to be just the package and the target machine override
        localdata.setVar("OVERRIDES", override + ":" + pkg + ":")
        # Expand the variable name with the current PN
        var_name = "pkg_postinst_ontarget:%s" % pkg
        return localdata.getVar(var_name) or ""

    postinst_ontarget_extra = ""

    if machine.startswith('lorix-one-'):
        postinst_ontarget_extra += get_var_with_override('lorix_one')

    if machine.startswith('l1'):
        postinst_ontarget_extra += get_var_with_override('l1')

    if postinst_ontarget_extra:

        postinst_ontarget = d.getVar('pkg_postinst_ontarget:%s' % pkg)
        if not postinst_ontarget:
            postinst_ontarget = '#!/bin/sh\n'

        postinst_ontarget += postinst_ontarget_extra

        d.setVar('pkg_postinst_ontarget:%s' % pkg, postinst_ontarget)
}

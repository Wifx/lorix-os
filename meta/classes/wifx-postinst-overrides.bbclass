PACKAGESPLITFUNCS:prepend = "populate_packages_overrides "
populate_packages_overrides[vardeps] += "pkg_postinst_ontarget:lorix_one pkg_postinst_ontarget:l1"

python populate_packages_overrides() {
    pkg = d.getVar('PN', True)
    machine = d.getVar('MACHINE', True)

    # Add pkg to the overrides so that it finds the OPENRC_SERVICES:pkg
    # variable.
    localdata = d.createCopy()
    localdata.prependVar("OVERRIDES", pkg + ":")

    if machine.startswith('lorix-one-'):
        postinst_ontarget = d.getVar('pkg_postinst_ontarget:%s' % pkg)
        if not postinst_ontarget:
            postinst_ontarget = '#!/bin/sh\n'
        
        extra = localdata.getVar('pkg_postinst_ontarget:%s:lorix_one' % pkg) or ""
        postinst_ontarget += extra
        d.setVar('pkg_postinst_ontarget:%s' % pkg, postinst_ontarget)

    if machine.startswith('l1'):
        postinst_ontarget = d.getVar('pkg_postinst_ontarget:%s' % pkg)
        if not postinst_ontarget:
            postinst_ontarget = '#!/bin/sh\n'
        
        extra = localdata.getVar('pkg_postinst_ontarget:%s:l1' % pkg) or ""
        postinst_ontarget += extra
        d.setVar('pkg_postinst_ontarget:%s' % pkg, postinst_ontarget)
}

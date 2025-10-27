# Copyright (c) 2025, Wifx SA <info@iot.wifx.net>
# All rights reserved.

# upx.bbclass - UPX compression for specific binaries in packages
#
# Usage in recipe:
# inherit upx
# UPX_COMPRESS_FILES:package-name = "/path/to/binary1 /path/to/binary2"
# UPX_COMPRESS_ENABLE = "true"  # Global enable/disable (accepts true/1/yes/on)
# UPX_COMPRESS_ENABLE:package-name = "false"  # Per-package override
#
# Example:
# UPX_COMPRESS_ENABLE = "1"
# UPX_COMPRESS_FILES:mender-update = "/usr/bin/mender-update"
# UPX_COMPRESS_FILES:mender-auth = "/usr/bin/mender-auth"
# UPX_COMPRESS_ENABLE:mender-auth = "0"  # Disable only for mender-auth

# NOTE: UPX compression is done at the end of the package split instead of
# before. Doing it this way allow us to avoid removing already-stripped check.

# Helper function to check if UPX is enabled for a specific package
def upx_is_enabled_for_package(d, pkg):
    """
    Check if UPX compression is enabled for a specific package.
    Per-package setting takes precedence over global setting.
    """
    import bb.utils

    # Check per-package setting first
    pkg_enable = d.getVar('UPX_COMPRESS_ENABLE:' + pkg)
    if pkg_enable is not None:
        return bb.utils.to_boolean(pkg_enable)

    # Fall back to global setting
    global_enable = d.getVar('UPX_COMPRESS_ENABLE')
    if global_enable is not None:
        return bb.utils.to_boolean(global_enable)

    # Default: disabled
    return False

# Validation and dependency management function
python __anonymous() {
    if bb.data.inherits_class('native', d) or bb.data.inherits_class('nativesdk', d):
        return

    packages = (d.getVar('PACKAGES') or '').split()

    # Skip if no packages defined yet
    if not packages:
        return

    # Build vardeps dynamically for all UPX-related variables
    vardeps = set()
    
    # Add global enable variable
    vardeps.add('UPX_COMPRESS_ENABLE')
    vardeps.add('UPX_COMPRESS_LEVEL')
    
    # Add per-package variables for all packages
    for pkg in packages:
        vardeps.add(f'UPX_COMPRESS_ENABLE:{pkg}')
        vardeps.add(f'UPX_COMPRESS_FILES:{pkg}')
    
    # Set vardeps for the packaging function
    current_vardeps = d.getVarFlag('do_package', 'vardeps') or ''
    new_vardeps = current_vardeps + ' ' + ' '.join(sorted(vardeps))
    d.setVarFlag('do_package', 'vardeps', new_vardeps.strip())

    # 1. Validate UPX_COMPRESS_FILES package names
    all_vars = d.keys()
    upx_vars = [var for var in all_vars if var.startswith('UPX_COMPRESS_FILES:')]

    errors = []
    for var in upx_vars:
        pkg_name = var.replace('UPX_COMPRESS_FILES:', '')
        # Expand variables like ${PN}
        expanded_pkg = d.expand(pkg_name)

        if expanded_pkg not in packages:
            errors.append({
                'var': var,
                'original': pkg_name,
                'expanded': expanded_pkg
            })

    if errors:
        bb.error("UPX configuration errors found:")
        for error in errors:
            if error['original'] != error['expanded']:
                bb.error(f"  Variable: {error['var']} (expands to: UPX_COMPRESS_FILES:{error['expanded']})")
            else:
                bb.error(f"  Variable: {error['var']}")
            bb.error(f"  Package '{error['expanded']}' does not exist")
        bb.error(f"Available packages: {', '.join(sorted(packages))}")
        bb.fatal("Fix UPX package configuration")

    # 2. Add upx-native dependency if UPX is enabled somewhere
    upx_needed = False

    # Check global enable
    global_enable = bb.utils.to_boolean(d.getVar('UPX_COMPRESS_ENABLE'))
    if global_enable:
        upx_needed = True
    else:
        # Check per-package enables
        for pkg in packages:
            pkg_enable = d.getVar('UPX_COMPRESS_ENABLE:' + pkg)
            if bb.utils.to_boolean(pkg_enable):
                upx_needed = True
                break

    if upx_needed:
        d.appendVar('DEPENDS', ' upx-native')
}

# Main compression function
python package_do_compress_upx() {
    import os
    import subprocess

    if bb.data.inherits_class('native', d) or bb.data.inherits_class('nativesdk', d):
        bb.debug(1, "Skipping UPX compression for native/nativesdk build")
        return

    # Skip if no packages defined yet
    packages = (d.getVar('PACKAGES') or '').split()
    if not packages:
        return

    # Get packages-split directory
    pkgdest = d.getVar('PKGDEST')
    if not pkgdest or not os.path.exists(pkgdest):
        return

    # Get compression level (default to --best)
    compression_level = d.getVar('UPX_COMPRESS_LEVEL') or '--best'

    upx_processed_files = 0
    upx_total_packages = 0
    upx_skipped_packages = 0

    for pkg in packages:
        compress_files = d.getVar('UPX_COMPRESS_FILES:' + pkg)

        if not compress_files:
            continue

        # Check if UPX is enabled for this package
        if not upx_is_enabled_for_package(d, pkg):
            upx_skipped_packages += 1
            bb.debug(1, f"UPX compression disabled for package '{pkg}', skipping")
            continue

        upx_total_packages += 1

        # Package directory in packages-split
        pkg_dir = os.path.join(pkgdest, pkg)

        files_to_compress = compress_files.split()
        bb.note(f"Processing UPX compression for package '{pkg}': {len(files_to_compress)} file(s)")

        for file_path in files_to_compress:
            # Construct full path
            fullpath = f"{pkg_dir}{file_path}"

            bb.note(f"compressing {fullpath}...")
            try:
                subprocess.run(f"upx {fullpath} {compression_level} -q", shell=True, check=True)
                subprocess.run(f"upx -t {fullpath}", shell=True, check=True)
                upx_processed_files += 1
            except subprocess.CalledProcessError as error:
                bb.fatal("cannot compress file '%s' : %s" % (fullpath, error))
            except Exception as error:
                bb.fatal("cannot compress file '%s' : %s" % (fullpath, error))

    # Summary logging
    if upx_total_packages > 0:
        bb.note(f"UPX compression completed: {upx_processed_files} file(s) processed across {upx_total_packages} package(s)")
        if upx_skipped_packages > 0:
            bb.note(f"UPX compression: {upx_skipped_packages} package(s) skipped (disabled)")
}

# Add the compression function to package split functions
PACKAGESPLITFUNCS:append = " package_do_compress_upx"

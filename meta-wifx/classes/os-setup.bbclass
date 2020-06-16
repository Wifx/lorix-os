
python __anonymous () {
    if bb.utils.contains('DISTRO_FEATURES', 'motd-dynamic', True, False, d) and not bb.utils.contains('DISTRO_FEATURES', 'pam', True, False, d):
        bb.fatal('Feature "pam" is required in DISTRO_FEATURES if "motd-dynamic" is enabled')
}
# Copyright (c) 2019-2020, Wifx Sàrl <info@wifx.net>
# All rights reserved.

do_install_append() {
    if ${@bb.utils.contains('DISTRO_FEATURES','motd-dynamic','true','false',d)}; then
        if [ -e ${D}${sysconfdir}/pam.d/sshd ]; then
            cat >> ${D}${sysconfdir}/pam.d/sshd <<EOF
# Print the message of the day upon successful login.
# This includes a dynamically generated part from /run/motd.dynamic
# and a static (admin-editable) part from /etc/motd.
session    optional     pam_motd.so motd=/run/motd.dynamic
session    optional     pam_motd.so noupdate
EOF
        fi
    fi
}

# Copyright (c) 2019-2020, Wifx Sàrl <info@wifx.net>
# All rights reserved.

do_install_append() {
    if ${@bb.utils.contains('DISTRO_FEATURES','motd-dynamic','true','false',d)}; then
        if [ -e ${D}${sysconfdir}/pam.d/login ]; then
            # Add support of motd-dynamic feature in login file
            sed -i  '/pam_motd.so/ c\# This includes a dynamically generated part from /run/motd.dynamic\
# and a static (admin-editable) part from /etc/motd.\
session    optional   pam_motd.so motd=/run/motd.dynamic\
session    optional   pam_motd.so noupdate' ${D}${sysconfdir}/pam.d/login
        fi
    fi
}

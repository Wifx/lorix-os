# Copyright (c) 2019-2020, Wifx SA <info@wifx.net>
# All rights reserved.

inherit extrausers

# Let sudo group user to execute any command
update_sudoers(){
    sed -i 's|# %sudo|%sudo|' ${IMAGE_ROOTFS}/etc/sudoers
}
ROOTFS_POSTPROCESS_COMMAND += "update_sudoers;"

# printf "%q" $(mkpasswd -m sha256crypt lorix4u)
PWD = "\$5\$oMzTaptCua3XzAjm\$E.TMGgrEDuJ.xF23NDcc/CIly0GqMxKD1cKZDTSyXQA"

EXTRA_USERS_PARAMS = " useradd -u 1000 admin; \
                       usermod -p '${PWD}' admin; \
                       usermod -a -G sudo admin; \
                       passwd-expire admin;"

# Copyright (c) 2019-2020, Wifx Sàrl <info@wifx.net>
# All rights reserved.

inherit extrausers

# Let sudo group user to execute any command
update_sudoers(){
    sed -i 's|# %sudo|%sudo|' ${IMAGE_ROOTFS}/etc/sudoers
}
ROOTFS_POSTPROCESS_COMMAND += "update_sudoers;"

EXTRA_USERS_PARAMS = " useradd -u 1000 admin; \
                       usermod -P 'lorix4u' admin; \
                       usermod -a -G sudo admin;"
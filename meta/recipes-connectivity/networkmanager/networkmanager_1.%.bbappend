# Copyright (c) 2022, Wifx Sarl <info@iot.wifx.net>
# All rights reserved.

do_install_append() {
    # Replace original 85-nm-unmanaged.rules files to manage gadget interfaces
    if [ -e ${D}/lib/udev/rules.d/85-nm-unmanaged.rules ]; then
        sed -e '/ENV{DEVTYPE}=="gadget"\,\ ENV{NM_UNMANAGED}="1"/ s/^#*/#/' -i ${D}/lib/udev/rules.d/85-nm-unmanaged.rules
    fi
}

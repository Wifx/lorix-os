# Copyright (c) 2022, Wifx Sarl <info@iot.wifx.net>
# All rights reserved.

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI += " \
    file://usb-dhcp.initd \
    file://usb-gadget.initd \
"

inherit openrc

RDEPENDS_${PN} += "machine-info"

OPENRC_SERVICE_${PN} = "usb-dhcp usb-gadget"
OPENRC_RUNLEVEL_usb-dhcp = "default"
OPENRC_RUNLEVEL_usb-gadget = "default"

do_install_append() {
    # Install OpenRC script
    openrc_install_script ${WORKDIR}/usb-dhcp.initd
    openrc_install_script ${WORKDIR}/usb-gadget.initd
}

python do_fill_script() {
    import os

    path = oe.path.join(d.getVar('D'), d.getVar('OPENRC_INITDIR'), 'usb-gadget')
    if not os.path.exists(path):
        bb.error("The file '%s' doesn't exist, is this recipe broken ?" % path)

    f = open(path, 'r')
    filedata = f.read()
    f.close()

    pid = ''
    product_name = ''
    machine = d.getVar('MACHINE')
    if machine == 'lorix-one-256' or machine == 'lorix-one-512':
        pid = '0x0001'
        product_name = 'Wifx LORIX One'
    elif machine == 'l1':
        pid = '0x0002'
        product_name = 'Wifx L1'
    else:
        bb.fatal("The machine '%s' is not supported by this recipe or PID has not been defined yet" % machine)

    filedata = filedata.replace('@{PID_SERIAL_RNDIS}', pid)
    filedata = filedata.replace('@{PRODUCT_NAME}', product_name)

    f = open(path, 'w')
    f.write(filedata)
    f.close
}

python __anonymous() {
    bb.build.addtask('do_fill_script', 'do_package', 'do_install', d)
}

# Copyright (c) 2025, Wifx SA <info@iot.wifx.net>
# All rights reserved.

inherit openrc
OPENRC_SERVICES = "udev-trigger udev-settle"
OPENRC_RUNLEVEL:udev-trigger = "sysinit"
OPENRC_RUNLEVEL:udev-settle = "default"
OPENRC_AUTO_ENABLE = "enable"

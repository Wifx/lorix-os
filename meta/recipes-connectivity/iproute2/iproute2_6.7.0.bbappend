# Copyright (c) 2025, Wifx SA <info@iot.wifx.net>
# All rights reserved.

# Configure netfilter backend for iproute2
# When using nftables instead of iptables, some tc modules may not build properly
# This provides a clean solution by adjusting the build configuration

FIREWALL_BACKEND ??= "nftables"

# Override only the DEPENDS, keeping all other configurations from base recipe
DEPENDS:remove = "iptables"
DEPENDS:append = " ${@bb.utils.contains('FIREWALL_BACKEND', 'nftables', 'nftables', 'iptables', d)}"

# When using nftables, adjust IPROUTE2_MAKE_SUBDIRS to handle tc properly
IPROUTE2_MAKE_SUBDIRS = "${@bb.utils.contains('FIREWALL_BACKEND', 'nftables', 'lib ip bridge misc genl', 'lib tc ip bridge misc genl', d)} ${@bb.utils.filter('PACKAGECONFIG', 'devlink tipc rdma', d)}"

# Adjust package list when tc is not built
IPROUTE2_PACKAGES:remove = "${@bb.utils.contains('FIREWALL_BACKEND', 'nftables', '${PN}-tc', '', d)}"

# Note: With nftables backend, tc (traffic control) is excluded to avoid build issues
# Most tc functionality can be achieved through nftables QoS features instead
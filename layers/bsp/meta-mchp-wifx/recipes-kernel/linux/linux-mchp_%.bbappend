# Pull in Poky's generic exclusions (platform-specific, historically incorrect CPEs…)
include recipes-kernel/linux/cve-exclusion.inc

# Version-based exclusions generated for 6.12 (run generate-cve-exclusions.py to update)
include ${THISDIR}/cve-exclusion_6.12.inc

# Config-based exclusions: subsystems not enabled in this project's defconfig
# KCONFIG_MODE=alldefconfig means everything not listed in defconfig is =n

# Wireless LAN — CONFIG_WLAN is not set
CVE_STATUS_GROUPS += "CVE_STATUS_WLAN"
CVE_STATUS_WLAN = "\
    CVE-2022-42722 \
    CVE-2022-42721 \
    CVE-2022-42720 \
    CVE-2022-42719 \
    CVE-2022-41674 \
"
CVE_STATUS_WLAN[status] = "not-applicable-config: CONFIG_WLAN is not set in the project defconfig"

# HID / input — CONFIG_HID, CONFIG_USB_HID, CONFIG_INPUT_KEYBOARD, CONFIG_INPUT_MOUSE are not set
CVE_STATUS_GROUPS += "CVE_STATUS_HID"
CVE_STATUS_HID = "\
    CVE-2023-25012 \
    CVE-2022-27950 \
"
CVE_STATUS_HID[status] = "not-applicable-config: CONFIG_HID is not set in the project defconfig"

# IOMMU — CONFIG_IOMMU_SUPPORT is not set
CVE_STATUS_GROUPS += "CVE_STATUS_IOMMU"
CVE_STATUS_IOMMU = ""
CVE_STATUS_IOMMU[status] = "not-applicable-config: CONFIG_IOMMU_SUPPORT is not set in the project defconfig"

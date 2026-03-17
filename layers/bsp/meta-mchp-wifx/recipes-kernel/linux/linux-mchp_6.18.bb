require linux-mchp.inc

LIC_FILES_CHKSUM = "file://COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"

LINUX_VERSION_SHORT = "6.18"
LINUX_VERSION = "6.18.6"
LINUX_VERSION_EXTENSION = "-wifx"

SRCREV_machine = "7040550e4935eede520706bcec063fa20251a0e6"
SRCREV_meta = "104a5c9d30a5d90664b80accec85db6b11449d8f"

# Disable config check: current poky/oe-core (scarthgap) kconfiglib doesn’t 
# support Kconfig keyword “transitional” (e.g., CFI_CLANG), causing parse 
# errors. 
# Re-enable after updating poky/oe-core.
do_kernel_configcheck[noexec] = "1"

# Not stable yet so prefer 6.12 for now.
DEFAULT_PREFERENCE = "-1"

SRC_URI += " \
    file://0001-Add-optionnal-customization-of-Atmel-NAND-PMECC-para.patch \
    file://0002-Add-i2c3-bus-support-for-SAMA5D4x-family-processor-i.patch \
    file://0003-lte-add-Fibocom-L610-MC610-support-in-option-driver.patch \
    file://0004-net-macb-manage-BNA-error-and-prevent-RX-lockup-on-G.patch \
    file://0005-usb-gadget-u_ether-harden-netdev-parent-handling-acr.patch \
    file://0006-usb-gadget-atmel_usba_udc-add-basic-USB-role-switch-.patch \
    file://0007-usb-gadget-atmel_usba_udc-complete-mux-and-disconnec.patch \
    file://0008-usb-gadget-atmel_usba_udc-defer-suspend-and-wakeup-c.patch \
    file://0009-usb-gadget-atmel_usba_udc-make-PM-suspend-resume-rol.patch \
    file://0010-usb-gadget-atmel_usba_udc-finalize-role-switch-lifec.patch \
    file://0011-usb-gadget-atmel_usba_udc-add-FSM-and-fix-clock-PM-r.patch \
    file://0012-usb-host-ohci-at91-harden-optional-VBUS-OC-GPIO-hand.patch \
    file://0013-wifx-add-support-for-LORIX-One-and-Wifx-L1-LoRaWAN-g.patch \
    file://0014-wifx-l1-dts-remove-useless-bool-argument-for-i2c-fil.patch \
    file://0015-watchdog-sama5d4-register-driver-earlier-at-boot.patch \
"

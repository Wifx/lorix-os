# CVE exclusions for libexpat, exported to the CycloneDX VEX by meta-cyclonedx.
#
# All of these are denial-of-service or crash issues that need attacker-supplied XML.
# On the LORIX OS image, libexpat is only used by dbus-daemon (+ dbus-daemon-launch-helper)
# and avahi-daemon, which only parse root-owned configuration and service files, never
# XML received from the network or from unprivileged users.
# Re-evaluate if another package starts depending on libexpat.

CVE_STATUS_GROUPS += "CVE_STATUS_EXPAT_TRUSTED_INPUT"
CVE_STATUS_EXPAT_TRUSTED_INPUT = "\
    CVE-2026-66046 \
    CVE-2026-113351 \
    CVE-2026-115506 \
    CVE-2026-117610 \
    CVE-2026-118370 \
"
CVE_STATUS_EXPAT_TRUSTED_INPUT[status] = "not-applicable-config: libexpat is only used by dbus-daemon and avahi-daemon to parse root-owned local configuration files, never untrusted XML"

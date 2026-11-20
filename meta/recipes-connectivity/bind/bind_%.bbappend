# CVE exclusions for BIND, exported to the CycloneDX VEX by meta-cyclonedx.
#
# The LORIX OS image only ships the BIND client tools (dig, host, nslookup) and their
# libraries. named (the recursive resolver / authoritative server) and delv (the DNSSEC
# validating lookup tool) are not installed. Re-evaluate if either is added to an image.

CVE_STATUS_GROUPS += "CVE_STATUS_BIND_NO_RESOLVER"
CVE_STATUS_BIND_NO_RESOLVER = "\
    CVE-2026-11331 \
    CVE-2026-11622 \
    CVE-2026-11721 \
    CVE-2026-12617 \
    CVE-2026-13204 \
    CVE-2026-13321 \
"
CVE_STATUS_BIND_NO_RESOLVER[status] = "not-applicable-config: affects the named resolver/validator only; named and delv are not installed, only the dig/host/nslookup client tools"

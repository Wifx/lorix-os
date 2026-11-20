# CVE exclusions for PCRE2, exported to the CycloneDX VEX by meta-cyclonedx.
#
# The issue needs pcre2_jit_match() to be given match data holding a subject copied by a
# previous match with PCRE2_COPY_MATCHED_SUBJECT. On the LORIX OS image, pcre2_jit_match is
# only called by glib (GRegex), which never sets that flag; grep and syslog-ng do not use
# it either. Re-evaluate if another package starts using PCRE2_COPY_MATCHED_SUBJECT.

CVE_STATUS[CVE-2026-89161] = "not-applicable-config: no user of pcre2_jit_match on the image sets PCRE2_COPY_MATCHED_SUBJECT"

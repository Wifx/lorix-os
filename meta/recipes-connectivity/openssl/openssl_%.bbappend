# CVE exclusions for OpenSSL, exported to the CycloneDX VEX by meta-cyclonedx.
#
# On the LORIX OS image, the only binary using the DTLS, QUIC or SSL_set_SSL_CTX() APIs is
# the openssl command-line tool. No service uses them (checked dynamic symbol imports of
# openvpn, wpa_supplicant, pppd, mender, syslog-ng, bind libraries and libcurl).
# Re-evaluate if a package using DTLS, QUIC or SNI-based SSL_CTX switching is added.

CVE_STATUS_GROUPS += "CVE_STATUS_OPENSSL_NO_DTLS"
CVE_STATUS_OPENSSL_NO_DTLS = "CVE-2026-84782"
CVE_STATUS_OPENSSL_NO_DTLS[status] = "not-applicable-config: DTLS is not used by any service on the image, only reachable through the openssl CLI tool"

CVE_STATUS_GROUPS += "CVE_STATUS_OPENSSL_NO_QUIC"
CVE_STATUS_OPENSSL_NO_QUIC = "CVE-2026-54873 CVE-2026-84784"
CVE_STATUS_OPENSSL_NO_QUIC[status] = "not-applicable-config: the OpenSSL QUIC stack is not used by any service on the image, only reachable through the openssl CLI tool"

CVE_STATUS_GROUPS += "CVE_STATUS_OPENSSL_NO_CTX_SWITCH"
CVE_STATUS_OPENSSL_NO_CTX_SWITCH = "CVE-2026-72897"
CVE_STATUS_OPENSSL_NO_CTX_SWITCH[status] = "not-applicable-config: no TLS server on the image calls SSL_set_SSL_CTX(), only the openssl CLI tool"

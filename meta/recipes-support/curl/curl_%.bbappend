# CVE exclusions for libcurl, exported to the CycloneDX VEX by meta-cyclonedx.
#
# On the LORIX OS image, libcurl4 is only pulled in by syslog-ng and only linked by its
# http() and cloud-auth() destination modules (usr/lib/syslog-ng/libhttp.so,
# libcloud_auth.so). The curl CLI is not installed. Users can configure an http()
# destination, so the exclusions below do NOT rely on http() being unused: they rely on
# the libcurl build options, or on libcurl options that syslog-ng never sets whatever
# the user configuration is (checked against syslog-ng 4.6.0 modules/http/http-worker.c
# and modules/cloud-auth/google-auth.cpp).
#
# Re-evaluate on a curl PACKAGECONFIG change, a syslog-ng upgrade, or if another package
# starts depending on libcurl.

# Features not compiled into libcurl
CVE_STATUS_GROUPS += "CVE_STATUS_CURL_NO_HTTP2"
CVE_STATUS_CURL_NO_HTTP2 = "CVE-2026-18924"
CVE_STATUS_CURL_NO_HTTP2[status] = "not-applicable-config: HTTP/2 Server Push requires HTTP/2 support, and libcurl is built without nghttp2"

CVE_STATUS_GROUPS += "CVE_STATUS_CURL_NO_GSSAPI"
CVE_STATUS_CURL_NO_GSSAPI = "CVE-2026-19931"
CVE_STATUS_CURL_NO_GSSAPI[status] = "not-applicable-config: Negotiate authentication requires GSS-API/SSPI, and libcurl is built without either"

# Features compiled in, but never enabled by the only libcurl user (syslog-ng)
CVE_STATUS_GROUPS += "CVE_STATUS_CURL_NO_DIGEST"
CVE_STATUS_CURL_NO_DIGEST = "CVE-2026-11856"
CVE_STATUS_CURL_NO_DIGEST[status] = "not-applicable-config: syslog-ng never sets CURLOPT_HTTPAUTH, so libcurl only uses Basic authentication and Digest is never selected, whatever the http() configuration"

CVE_STATUS_GROUPS += "CVE_STATUS_CURL_NO_COOKIES"
CVE_STATUS_CURL_NO_COOKIES = "CVE-2026-8924"
CVE_STATUS_CURL_NO_COOKIES[status] = "not-applicable-config: syslog-ng never enables the libcurl cookie engine (no CURLOPT_COOKIEFILE/COOKIEJAR/COOKIELIST), whatever the http() configuration"

# Not excluded: CVE-2026-8927 (proxy authentication state kept across transfers when the
# proxy comes from environment variables). syslog-ng reuses one curl handle per http()
# worker and, without proxy(), libcurl honours http_proxy/https_proxy, so it can apply
# when a user configures an http() destination behind a proxy.

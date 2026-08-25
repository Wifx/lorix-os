require chirpstack-concentratord-legacy.inc
require chirpstack-concentratord-legacy-crates_${PV}.inc

SRC_URI += " \
    git://github.com/brocaar/chirpstack-concentratord.git;protocol=https;branch=master \
    file://0001-vendor-LORIX-One-support-version-8XX-and-9XX-hardwar.patch \
    file://0002-vendor-Wifx-L1-support-version-8XX-and-9XX-hardware-.patch \
    file://0003-vendor-Wifx-LORIX-One-and-L1-support-for-LoRa-fronte.patch \
    file://0004-Update-bindgen-to-0.72.patch \
    file://0005-build-update-docker-image-rust-1.82-and-remove-new-v.patch \
    file://0006-Purge-expired-JIT-items-before-reporting-QueueFull.patch \
    file://0007-bump-to-3.3.1-wifx-0.2.patch \
"
SRCREV = "491450db7917c198360b923e93ae899c3445c201"

PR = "r2"

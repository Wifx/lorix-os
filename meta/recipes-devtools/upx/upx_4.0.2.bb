include upx-4.inc

SRC_URI = " \
    https://github.com/upx/upx/releases/download/v${PV}/upx-${PV}-src.tar.xz \
"
PR = "r0"

SRC_URI[sha256sum] = "1221e725b1a89e06739df27fae394d6bc88aedbe12f137c630ec772522cbc76f"

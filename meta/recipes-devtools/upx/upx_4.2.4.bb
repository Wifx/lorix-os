include upx-4.inc

SRC_URI = " \
    https://github.com/upx/upx/releases/download/v${PV}/upx-${PV}-src.tar.xz \
"
PR = "r0"

SRC_URI[sha256sum] = "5ed6561607d27fb4ef346fc19f08a93696fa8fa127081e7a7114068306b8e1c4"

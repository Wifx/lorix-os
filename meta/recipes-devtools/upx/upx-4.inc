DESCRIPTION = "The Ultimate Packer for eXecutables"
HOMEPAGE = "https://upx.github.io/"
SUMMARY = "Ultimate executable compressor."

LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://LICENSE;md5=353753597aa110e0ded3508408c6374a"

S = "${WORKDIR}/upx-${PV}-src"

BBCLASSEXTEND = "native"

inherit pkgconfig cmake

DEPENDS = "zlib libucl xz"

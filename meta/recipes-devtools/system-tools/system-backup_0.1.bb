SUMMARY = "Backup and Restore Utility"
DESCRIPTION = "A script to create and restore system backups."
LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=9e49b0f53e193f3ef828813f1092c705"

SRC_URI = " \
    file://LICENSE \
    file://backup.sh \
"

S = "${WORKDIR}"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/backup.sh ${D}${bindir}/backup
}

RDEPENDS:${PN} = "bash manager machine-info libubootenv tar coreutils grep sed"

require syslog-ng.inc

# We only want to add stuff we need to the defaults provided in syslog-ng.inc.
#
SRC_URI += " \
           file://syslog-ng.service-the-syslog-ng-service.patch \
           file://syslog-ng-tmp.conf \
           "

SRC_URI[md5sum] = "efd9e1dc70090500b43f5d366be7dae0"
SRC_URI[sha256sum] = "0b786a06077b9150191d714f45a1b4b3792952cb58163a3af336f074da9fb14b"

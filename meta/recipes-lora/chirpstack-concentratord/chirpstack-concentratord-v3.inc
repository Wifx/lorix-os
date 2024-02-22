LIC_FILES_CHKSUM = "file://LICENSE;md5=99e425257f8a67b7efd81dc0009ed8ff"

FILESEXTRAPATHS:prepend := "${THISDIR}/v3:"

DEPENDS += "clang-native"
ASSUME_PROVIDED:remove = "cmake-native"

include chirpstack-concentratord.inc

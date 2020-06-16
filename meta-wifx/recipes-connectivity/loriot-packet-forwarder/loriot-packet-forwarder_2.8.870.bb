include loriot-packet-forwarder.inc
PR = "r0"

SRC_URI += " \
	file://loriot_lorix_one_SPI_2.8.870-JKS-EU-1 \
"

BIN_SRC_FILE_NAME = "loriot_lorix_one_SPI_2.8.870-JKS-EU-1"

RDEPENDS_${PN} += "libcrypto openssl"

INSANE_SKIP_${PN} += "file-rdeps"

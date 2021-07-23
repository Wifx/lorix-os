#!/bin/sh

# This script is intended to be used on SX1302 CoreCell platform, it performs
# the following actions:
#       - export/unpexort GPIO1 and GPIO11 used to reset the SX1302 chip and to enable the LDOs
#
# Usage examples:
#       ./reset_lgw.sh stop
#       ./reset_lgw.sh start

# GPIO mapping has to be adapted with HW
#

SX1302_RESET_PIN_ID=1
SX1302_RESET_PIN=pioA1

SX1302_POWER_EN_PIN_ID=11
SX1302_POWER_EN_PIN=pioA11

WAIT_GPIO() {
    sleep 0.1
}

init() {
    # setup GPIOs
    echo "$SX1302_RESET_PIN_ID" > /sys/class/gpio/export; WAIT_GPIO
    echo "$SX1302_POWER_EN_PIN_ID" > /sys/class/gpio/export; WAIT_GPIO

    # set GPIOs as output
    echo "out" > /sys/class/gpio/$SX1302_RESET_PIN/direction; WAIT_GPIO
    echo "out" > /sys/class/gpio/$SX1302_POWER_EN_PIN/direction; WAIT_GPIO
}

reset() {
    echo "CoreCell reset through GPIO $SX1302_RESET_PIN..."
    echo "CoreCell power enable through GPIO $SX1302_POWER_EN_PIN..."

    # write output for SX1302 CoreCell power_enable and reset
    echo "1" > /sys/class/gpio/$SX1302_POWER_EN_PIN/value; WAIT_GPIO

    echo "1" > /sys/class/gpio/$SX1302_RESET_PIN/value; WAIT_GPIO
    echo "0" > /sys/class/gpio/$SX1302_RESET_PIN/value; WAIT_GPIO
}

term() {
    # cleanup all GPIOs
    if [ -d /sys/class/gpio/$SX1302_RESET_PIN ]
    then
        echo "$SX1302_RESET_PIN_ID" > /sys/class/gpio/unexport; WAIT_GPIO
    fi
    if [ -d /sys/class/gpio/$SX1302_POWER_EN_PIN ]
    then
        echo "$SX1302_POWER_EN_PIN_ID" > /sys/class/gpio/unexport; WAIT_GPIO
    fi
}

case "$1" in
    start)
    term # just in case
    init
    reset
    ;;
    stop)
    reset
    term
    ;;
    *)
    echo "Usage: $0 {start|stop}"
    exit 1
    ;;
esac

exit 0
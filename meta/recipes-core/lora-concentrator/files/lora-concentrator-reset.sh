#!/bin/bash
# Copyright (c) 2019-2020, Wifx Sàrl <info@wifx.net>
# All rights reserved.

PIN=${LORA_CORE_RST_PIN:-1}
PIN_PATH=${LORA_CORE_RST_PIN_PATH:-/sys/class/gpio/pioA1}

wait_gpio() {
    sleep 0.01
}

reset() {
    # setup GPIOA1
    echo ${PIN} > /sys/class/gpio/export

    # set GPIOA1 as output
    echo "out" > ${PIN_PATH}/direction; wait_gpio

    # write output for SX130X reset
    echo "1" > ${PIN_PATH}/value; wait_gpio
    echo "0" > ${PIN_PATH}/value; wait_gpio

    # unexport GPIOA1
    echo ${PIN} > /sys/class/gpio/unexport
}

reset

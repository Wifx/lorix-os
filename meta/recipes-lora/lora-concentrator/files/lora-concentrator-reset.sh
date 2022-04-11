#!/bin/sh
# Copyright (c) 2019-2020, Wifx Sàrl <info@wifx.net>
# All rights reserved.

CHIP=${LORA_CORE_RST_CHIP:-gpiochip0}
PIN=${LORA_CORE_RST_PIN:-1}
DELAY=${LORA_CORE_RST_DELAY_US:-100000}

gpioset --mode=time --usec=${DELAY} ${CHIP} ${PIN}=1
gpioset ${CHIP} ${PIN}=0

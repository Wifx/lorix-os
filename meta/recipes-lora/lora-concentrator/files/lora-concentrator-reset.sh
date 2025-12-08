#!/bin/sh
# Copyright (c) 2019-2020, Wifx SA <info@wifx.net>
# All rights reserved.

CHIP=${LORA_CORE_RST_CHIP:-gpiochip0}
PIN=${LORA_CORE_RST_PIN:-1}
DELAY=${LORA_CORE_RST_DELAY_MS:-100}

gpioset --toggle "${DELAY}ms,0" --chip ${CHIP} ${PIN}=1

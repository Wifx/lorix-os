#!/bin/bash
# Copyright (c) 2023, Wifx SA <info@iot.wifx.net>
# All rights reserved.

port=$1

display_usage() {
    echo "This script must be run with root privileges."
    echo -e "Usage: $(basename $0) [-h] path"
    echo -e "    -h     display this menu"
    echo -e "    path   modem path of the form /dev/XXX\n"
}

if [ $# -eq 0 ]; then
    echo -e "Error: argument missing\n"
    display_usage
    exit 1
fi

if [[ ( $@ == "--help") || $@ == "-h" ]]; then
    display_usage
    exit 0
fi

if [[ ! $port = /dev/* ]]; then
    echo -e "Error: path argument is not of the form /dev/XXX\n"
    display_usage
    exit 1
fi

if [[ "$EUID" -ne 0 ]]; then
    echo -e "Error: this script must be run as root!"
    exit 1
fi

if [ ! -c "$port" ]; then
    echo -e "Error: port '$port' doesn't exist"
    exit 1
fi

# Put the modem in ECM mode
echo -n -e "AT+GTUSBMODE=32\r\n" > $port

# Reset the modem
echo -n -e "AT+CFUN=15\r\n" > $port

exit 0

#!/bin/sh

module="g_serial"

has_sudo() {
    local prompt

    prompt=$(sudo -nv 2>&1)
    if [ $? -eq 0 ]; then
        return 0
    elif echo $prompt | grep -q '^sudo:'; then
        return 1
    else
        return 2
    fi
}

check_right() {
    has_sudo
    if [ $? -ne 0 ]; then
        echo "You don't have sufficient right, use sudo or become root"
        exit 1
    fi
}

is_loaded() {
    modinfo $module > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        return 1
    else
        return 0
    fi
}


load() {
    echo "load"
    check_right
    is_loaded

    if [ $? -eq 1 ]; then
        echo "Module $module is already loaded"
        exit 1
    fi

    modprobe $module
}

unload() {
    echo "unload"
    check_right
    is_loaded

    if [ $? -eq 0 ]; then
        echo "Module $module is not loaded"
        exit 1
    fi

    rmmod $module
}

case $1 in
    "load")
        load
        ;;
    "unload")
        unload
        ;;
    "help")
        echo "$0 <load|unload|help>"
        ;;
    *)
        echo "Command missing or not recognized"
        exit 1
        ;;
esac


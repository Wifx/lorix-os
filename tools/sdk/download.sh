#!/bin/bash

USAGE="Usage: download <sdk-version>"

if [ "$#" -lt 1 ]; then
    echo $USAGE
    exit 1
fi

VERSION_SDK=$1

SDK_SRC_URL=https://download.wifx.net/lorix-os/${VERSION_SDK}/sdk/lorix-os-glibc-x86_64-wifx-image-os-cortexa5t2hf-neon-vfpv4-lorix-one-512-toolchain-${VERSION_SDK}.sh

wget $SDK_SRC_URL -O sdk-installer.sh

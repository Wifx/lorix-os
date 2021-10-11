#!/bin/bash -x

USAGE="Usage: build <sdk-version> [yocto(default)|downloads] [sdk-path]"

if [ "$#" -lt 1 ]; then
    echo $USAGE
    exit 1
fi

VERSION_SDK=$1
VERSION_GO="1.16"

if [ "$#" -ge 2 ]; then
    case $2 in
        "yocto" | "Yocto" | "YOCTO" | "y")
            SOURCE="yocto"
            ;;

        "downloads" | "Downloads" | "DOWNLOADS" | "d")
            SOURCE="downloads"
            ;;

        *)
            echo $USAGE
            exit 1
            ;;
    esac
else
    SOURCE="yocto"
fi

SDK_SCRIPT_BASE_NAME=lorix-os-glibc-x86_64-wifx-image-os-cortexa5t2hf-neon-vfpv4-lorix-one-512-toolchain

if [[ ! -z "$3" ]]; then
    SDK_SRC_PATH=$3/${SDK_SCRIPT_BASE_NAME}-*.sh
else
    SDK_SRC_PATH=../../poky/build/tmp/deploy/sdk/${SDK_SCRIPT_BASE_NAME}-*.sh
fi

SDK_SRC_URL=https://download.wifx.net/lorix-os/${VERSION_SDK}/sdk/${SDK_SCRIPT_BASE_NAME}-${VERSION_SDK}.sh

case $SOURCE in
    "yocto")
        cp $SDK_SRC_PATH sdk-installer.sh
        ;;
    
    "downloads")
        wget $SDK_SRC_URL -O sdk-installer.sh
        ;;

    *)
        echo "Unknown source '$SOURCE'"
        exit 1
        ;;
esac

echo "Building OCI image for LORIX OS SDK v$VERSION from '$SOURCE'"

docker build \
    -t wifx/lorix-os-sdk:"$VERSION_SDK" \
    --build-arg GO_VERSION="$VERSION_GO" \
    --build-arg LORIXOS_TOOLCHAIN_VERSION="$VERSION_SDK" \
    lorix-os/tools/sdk

rm sdk-installer.sh

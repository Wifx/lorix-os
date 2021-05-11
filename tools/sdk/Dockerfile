FROM ubuntu:20.04

MAINTAINER Wifx "support@iot.wifx.net"

ENV DEBIAN_FRONTEND noninteractive

ARG WORKDIR=/root

# Essentials
RUN apt-get update
RUN apt-get install -y gawk wget git-core diffstat unzip texinfo gcc-multilib build-essential chrpath socat libsdl1.2-dev xterm
RUN apt-get clean

# LORIX OS toolchain
ARG LORIXOS_TOOLCHAIN_VERSION
ARG TOOLCHAIN_PATH=/opt/lorix-os/$LORIXOS_TOOLCHAIN_VERSION

COPY sdk-installer.sh .

RUN chmod +x sdk-installer.sh
RUN mkdir -p ${TOOLCHAIN_PATH}
RUN ./sdk-installer.sh -y -d ${TOOLCHAIN_PATH}
RUN rm sdk-installer.sh

# GO
ARG GO_VERSION
ARG GO_ARCHIVE_NAME=go${GO_VERSION}.linux-amd64.tar.gz

RUN wget https://golang.org/dl//${GO_ARCHIVE_NAME}
RUN tar -xvf ${GO_ARCHIVE_NAME}
RUN mv go /usr/local
RUN rm ${GO_ARCHIVE_NAME}

ENV GOROOT /usr/local/go
ENV GOPATH $WORKDIR
ENV PATH $GOROOT/bin:$PATH

# Setup
WORKDIR $WORKDIR
ENV TOOLCHAIN_PATH ${TOOLCHAIN_PATH}

ENV CGO_ENABLED 1
ENV GOOS linux
ENV GOARCH arm
ENV GOARM 7

ENTRYPOINT \
    . ${TOOLCHAIN_PATH}/environment-setup-cortexa5t2hf-neon-vfpv4-lorixos-linux-gnueabi && \
    export CGO_CFLAGS="-march=armv7-a -marm -mfpu=neon -mfloat-abi=hard -mcpu=cortex-a5 --sysroot=$SDKTARGETSYSROOT" && \
    export CGO_LDFLAGS="--sysroot=$SDKTARGETSYSROOT" && \
    /bin/bash

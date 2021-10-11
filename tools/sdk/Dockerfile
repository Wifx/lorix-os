FROM ubuntu:20.04

MAINTAINER Wifx "support@iot.wifx.net"

ENV DEBIAN_FRONTEND noninteractive

ARG WORKDIR=/root

# Essentials
RUN apt-get update
RUN apt-get install -y gawk wget git-core diffstat unzip texinfo gcc-multilib build-essential chrpath socat libsdl1.2-dev xterm
RUN apt-get clean

# LORIX OS toolchain
ARG TOOLCHAIN_PATH=/opt/lorix-os-sdk

COPY sdk-installer.sh .

RUN chmod +x sdk-installer.sh
RUN mkdir -p ${TOOLCHAIN_PATH}
RUN ./sdk-installer.sh -y -d ${TOOLCHAIN_PATH}
RUN rm sdk-installer.sh

# Setup
WORKDIR $WORKDIR
ENV TOOLCHAIN_PATH ${TOOLCHAIN_PATH}

ENTRYPOINT \
    . ${TOOLCHAIN_PATH}/environment-setup-cortexa5t2hf-neon-vfpv4-lorixos-linux-gnueabi && \
    /bin/bash

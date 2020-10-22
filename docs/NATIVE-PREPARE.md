# Prepare your native host system for a Yocto build

## Pre-requisites

* Git 1.8.3.1 or greater
* tar 1.28 or greater
* Python 3.5.0 or greater.
* gcc 5.0 or greater.

## Install the required packages

Install the following packages as described on the [Yocto required packages page](https://www.yoctoproject.org/docs/2.5/ref-manual/ref-manual.html#required-packages-for-the-host-development-system).

```shell
sudo apt-get install gawk wget git-core diffstat unzip texinfo gcc-multilib \
build-essential chrpath socat cpio python python3 python3-pip python3-pexpect \
xz-utils debianutils iputils-ping
```

## Create cache folders

By default, the Yocto configuration of LORIX OS will put its cache in /yocto. Therefore, you have to create this folder and give access right to the user that will build the image.

```
$ sudo mkdir /yocto
$ sudo chown you:you /yocto
```

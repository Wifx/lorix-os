# LORIX OS Build System (yocto) Quick Start

This workspace provides all the material needed to build a LORIX OS distribution for the Wifx LORIX gateways.

The LORIX OS documentation is available on https://iot.wifx.net/docs/lorix-os. This documention will focus on the LORIX OS Build System Quick Start.

## Supported products

* LORIX One 256MB
* LORIX One 512MB

## Pre-requisites

* Git
* 50 Gbytes of free disk space
* One of
  * A Linux based operating system compatible with Docker CE
  * Ubuntu 20.04

## Prepare your environment

### Download the workspace

Download the workspace using Git<br />
```shell
$ git clone --recursive -j8 https://github.com/Wifx/lorix-os
$ cd lorix-os
$ git submodule update
```

Display all the submodule status when git status is invoked in this repo:
```shell
$ git config --global status.submoduleSummary true
```
> **Note:** This option will affect globally your git settings and the other git repo containing submodules

### Install the dependencies

To meet the dependencies needed for the build, you have two possibilities:
  1. [**Docker**](docs/DOCKER-PREPARE.md): build into a Docker container containing all the dependencies
  2. [**Native**](docs/NATIVE-PREPARE.md): install the dependencies on your system

We recommend building into the Docker container as it will ensure a reproductible build without interfering with the host system.

Follow the guides provided by those links. Once the dependency installed, you will have a compatible host system and can go on with building the images.

## Add the initial configuration

Copy default configuration files from the lorix-os/tools directory:
```shell
$ cd lorix-os
$ mkdir -p poky/build/conf
$ cp tools/config/* poky/build/conf
```

> **Note**: The default 'machine' is the LORIX One 512MB. If want want to build for another machine, edit the `poky/build/conf/local.conf` file.

For other configuration changes, please check the [configuration documentation](docs/CONFIG.md).

## Build the images

From the workspace (`lorix-os` directory).

1. Enter the poky directory to configure the build system
   ```shell
   $ cd poky
   ```

2. **Initialize the build directory**
   ```shell
   $ source oe-init-build-env
   ```

   This will create the `lorix-os/poky/build` directory in which all the work will be done. The `build` directory becomes the active directory.

3. Build the Wifx standard image
   ```shell
   $ bitbake wifx-image-os
   ```

   Typical bitbake output:
   ```
   Build Configuration:
   BB_VERSION           = "1.44.0"
   BUILD_SYS            = "x86_64-linux"
   NATIVELSBSTRING      = "universal"
   TARGET_SYS           = "arm-lorixos-linux-gnueabi"
   MACHINE              = "lorix-one-512"
   DISTRO               = "lorix-os"
   DISTRO_VERSION       = "1.2.0"
   TUNE_FEATURES        = "arm vfp cortexa5 neon thumb callconvention-hard"
   TARGET_FPU           = "hard"
   meta                 
   meta-poky            
   meta-yocto-bsp       = "zeus:419c17a948791fed2a9ffc61826260630218abfd"
   meta-oe              
   meta-networking      
   meta-python          
   meta-multimedia      = "zeus:2b5dd1eb81cd08bc065bc76125f2856e9383e98b"
   meta-wifx            
   meta-wifx-lorix      
   meta-wifx-mender     
   meta-wifx-openrc     = "1.2.x:5ca77b49be72af5673c0ab729229f759c0eb67f2"
   meta-rust-bin        = "HEAD:94b68bde7d6fa8560be8648b4ba0fe188b555e5a"
   ```

   The build take around 1 to 3 hours, depending on your host computer's performance, the connexion speed and the host configuration (filesystem journalization, antivirus, ...).

## Extract the result

   * **System images**: the release images are located at `lorix-os/poky/build/tmp/deploy/images/<machine>/release`
     * Programmable image : `lorix-os-<version>_<machine>.wimg`<br />
       This image can be programmed to the gateway with the LORIX Programming tool
     * Update artifact : `lorix-os-<version>_<machine>.mender`<br />
       This _unsigned_ artifact can be used to upgrade a gateway though the upgrade system.<br />
       By default, an official LORIX OS build will not accept unsigned images. Please refer to [the official documentation](http://iot.wifx.net/docs) to see how to enable unsigned updates.
   * **Packages**: the system packages to use with opkg are located at `lorix-os/poky/build/tmp/deploy/images/<machine>/ipk`
     * If you want to provide these packages to your image, please check the `OS_DISTRO_FEEDS_BASE_URL` option of the `release.conf` file.

## Dependencies

This build workspace depends on:

* **meta-openembedded**<br />
  URI: [git://git.openembedded.org/meta-openembedded](git://git.openembedded.org/meta-openembedded)<br />
  Branch: zeus<br />

* **poky**<br />
  URI: [git://git.yoctoproject.org/poky](git://git.yoctoproject.org/poky)<br />
  Branch: zeus<br />

* **meta-rust-bin**<br />
  URI: [https://github.com/rust-embedded/meta-rust-bin.git](https://github.com/rust-embedded/meta-rust-bin.git)<br />


## Support

You may find additional help in the [Developer's Guide of the LORIX OS documentation](https://iot.wifx.net/docs/lorix-os/developer-s-guide);

Wifx's R&D team <support@iot.wifx.net>
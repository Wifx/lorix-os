# Wifx's LORIX family products distro OS
This workspace provides all the material needed to build a LORIX OS distribution for the LORIX One Wifx's gateway

## Supported machine
* LORIX One products (256 and 512MB versions)

## Sources

* lorix-os<br />
  URI: [https://git.wifx.net/yocto/lorix-os.git](https://git.wifx.net/yocto/lorix-os.git)<br />
  Branch: sumo

## Actual status

### Hardware support
| Memory version  | Overlayfs | Atomic update | Watchdog |
| --------------- | --------- | ------------- | -------- |
| 256MB NAND      | <span style="color:green">Done</span> | <span style="color:green">Done</span> | <span style="color:green">Done</span> |
| 256MB SD-Card   | <span style="color:red">Not started</span> | <span style="color:red">Not started</span> | <span style="color:red">Not started</span> |
| 512MB NAND      | <span style="color:green">Done</span> | <span style="color:green">Done</span> | <span style="color:green">Done</span> |
| 512MB SD-Card   | <span style="color:red">Not started</span> | <span style="color:red">Not started</span> | <span style="color:red">Not started</span> |

Details:
* **Overlayfs:** Dual partition design with data partition mounted as overlayfs over a single rootfs
* **Atomic update:** Triple partition design with data partition mounted as overlayfs over one of the two rootfs. Update of the "sleeping" rootfs using Mender.

### Software support
| Software parts       | Description | Status |
| -------------------- | ----------- | ------ |
| pvisor               | Light process supervisor, to be used<br/> for each process managed by the pmonitord | <span style="color:green">Stable</span> |
| pmonitord            | Process monitor daemon, handles managed<br/> processes lifecycle from birth to death | <span style="color:green">Stable</span> |
| manager              | LORIX unified manager, brings a global<br/>abstraction to manage the system, through<br/>web interface or command line interface | <span style="color:red">Stable</span> |
| udp-packet-forwarder | UDP Packet Forwarder, brings the bridge<br/>between the SX1301 LoRa concentrator<br/>hardware and the LoRa Network Server | <span style="color:green">Stable</span> |

## TODO

* Create doc: Map the Docker directory at a higher level to have a shared Yocto download directory between multiple Docker instance or between Docker and native Yocto
* Complete the Mender support + doc

## Dependencies
This build workspace depends on:

* **meta-wifx**<br />
  URI: [https://git.wifx.net/yocto/meta-wifx.git](https://git.wifx.net/yocto/meta-wifx.git)<br />
  Branch: sumo<br />
  Status: Important work in progress, not stable and highly subject to huge modification

* **meta-wifx-lorix**<br />
  URI: [https://git.wifx.net/yocto/meta-wifx-lorix.git](https://git.wifx.net/yocto/meta-wifx-lorix.git)<br />
  Branch: sumo<br />
  Status: Important work in progress, not stable and highly subject to huge modification

* **meta-wifx-mender**<br />
  URI: [https://git.wifx.net/yocto/meta-wifx-mender.git](https://git.wifx.net/yocto/meta-wifx-mender.git)<br />
  Branch: sumo<br />
  Status: Important work in progress, not stable and highly subject to huge modification

* **meta-wifx-openrc**<br />
  URI: [https://git.wifx.net/yocto/meta-wifx-openrc.git](https://git.wifx.net/yocto/meta-wifx-openrc.git)<br />
  Branch: sumo<br />
  Status: Important work in progress, not stable and highly subject to huge modification

* **meta-openembedded**<br />
  URI: [git://git.openembedded.org/meta-openembedded](git://git.openembedded.org/meta-openembedded)<br />
  Branch: sumo<br />
  Status: Stable

* **poky**<br />
  URI: [git://git.yoctoproject.org/poky](git://git.yoctoproject.org/poky)<br />
  Branch: sumo<br />
  Status: Stable

## Requirement
This workspace is known to work on Ubuntu 18.04LTS however, to garantee a stable and validated environnement, it is strongly recommended to use the Dockerfile provided in this workspace as explained below.

## Download the workspace

The following setup has to be done only once and can be passed for the next build.

Download the workspace using git<br />
```shell
$ cd work_directory
$ git clone --recursive -j8 https://git.wifx.net/yocto/lorix-os.git
$ cd lorix-os
$ git submodule update
```
> **Note:** The repositories are subject to change when they will be made publicly available.

Display all the submodule status when git status is invokey in this repo:
```shell
$ git config --global status.submoduleSummary true
```
> **Note:** This option will affect globally your git settings and then other git repo containing submodules

## Configure the build system using Docker (highly recommended)

1. **Install Docker CE** on your Linux based building system as explained in the Docker's documentation:
   1. [Ubuntu](https://docs.docker.com/install/linux/docker-ce/ubuntu/)
   2. [Debian](https://docs.docker.com/install/linux/docker-ce/debian/)
   3. [Fedora](https://docs.docker.com/install/linux/docker-ce/fedora/)
2. **Go inside the right Docker file directory** in the workspace repository:<br />
   ```shell
   $ cd work_directory/lorix-os/tools/docker/yocto-ubuntu-18.04
   ```
3. **Create the Docker image** by building this Dockerfile from its directory:
   ```shell
   $ sudo docker build -t yocto:ubuntu-18.04 .
   Sending build context to Docker daemon  3.584kB
   Step 1/18 : FROM ubuntu:18.04
    ---> cd6d8154f1e1
   Step 2/18 : ENV DEBIAN_FRONTENV noninteractive
   [...]
   Successfully built 2d5d9da4c7b1
   Successfully tagged yocto:ubuntu-18.04
   ```
   This Docker image is now available on your system and allows to create easily a container supporting the build of the Yocto system. Based on this system, you are always sure:
     * That the container is clean when you use it since we will use temporary container (deleted when you exit from it)
     * That the container contains all the packages you need to make Bitbake build system and Yocto working well
4. **Create a user** with rights in host and container:

   The Yocto build process will be done inside the Docker container and thus, files generated inside and shared through a volume should also be readable from outside. An easy solution is to create a user with the same ID inside the container and outside (inside the Docker host).

   The current Docker image create a user namely `build` with the user ID (uid) 5000. You then need to create a user in your host system with the same uid (user name doesn't matter). In our case, we create this user the with name `yocto` and assign a new password:
   ```shell
   $ sudo useradd -u 5000 yocto
   $ sudo passwd yocto
   New password:
   Retype new password:
   passwd: all authentication tokens updated successfully.
   ```
   Can you become this user temporary using the `su` command:
   ```shell
   user1@host $ su yocto
   Password:
   yocto@host $ (you are now yocto)
   yocto@host $ exit
   user1@host $ (you are not anymore yocto)
   ```
5. **Create a volume for the Docker container**

   Since Yocto generate a lot of files and especially a cache which permits to build "incrementaly" very quickly, it's really convenient to keep this cache outside of the container in order to reuse it even if the container is closed or destroyed. It's also very convenient to share the download directory of Yocto among multiple container (in team for example).

   This volume must be owned by the yocto user in order to be writable from inside the container.
   ```shell
   $ sudo mkdir -p /shared/yocto
   $ sudo chown yocto:yocto /shared/yocto
   ```

6. **Start the Docker container** and understand the directories mapping<br />
   We usually edit and modify the Yocto's configuration files (or package recipes) from the build host OS and keep the Docker container to only build the final image.

   To make the nexts explaination more easy to understand, we will define some values:
   *  **\<host dir\>**<br />
      The directory ```lorix-os``` containing your workspace on your host system. This directory is variable and depends really on your own configuration, for example ```/home/you/devel/lorix-os```
   *  **\<docker dir\>**<br />
      The directory in the Docker container where should be binded the **\<host directory\>**. This directory is fixed and should ideally ```/home/build```. This is where you are located when you start the Docker container.
   *  **\<vol host dir\>**<br />
      The directory used as volume mounting point on the host system which contains the shared state and download material (previously create as `/shared/yocto`)
   *  **\<vol docker dir\>**<br />
      The directory used as volume mounting point on the docker system (internaly mounted under `/yocto`)

   That being said, we need to start the yocto:ubuntu-18.04 Docker container:
   ```shell
   $ sudo docker run --rm -it -v <host dir>:<docker dir> -v <vol host dir>:<vol docker dir> yocto:ubuntu-18.04
   ```
   or
   ```shell
   $ sudo docker run --rm -it -v /home/you/devel/lorix-os:/home/build -v /shared/yocto:/yocto yocto:ubuntu-18.04
   build@dfe8e4eeb96f:~$ # you are now inside the container
   ```
   The ```--rm``` argument is used to make the container as temporary and to delete it when we quit. The ```-it``` stands for interactive (i) and tty (t) to open a terminal directly connecting the host therminal to the container's internal terminal.
   > **Note:** This command will be used each time you will need to launch the Yocto building Docker container.

   > **Note 2:** You can also use the argument ```--hostname=<hostname>``` when you start the container to give it a constant hostname instead of the random generator one.

7. Once inside the container, enter the poky directory to configure the build system
   ```shell
   build@dfe8e4eeb96f:~$ cd poky
   ```
8.  **Initialize the build directory**
    ```shell
    build@dfe8e4eeb96f:~$ source oe-init-build-env
    ```
    This will create the build directory in which all the work will be done. You can also have alternative build directories with different configurations  or different machines.
    To do so, you can create another build directory with a different name as follow:
    ```shell
    build@dfe8e4eeb96f:~$ source oe-init-build-env build-alt-name
    ```
    > **Note:** For example, you could have the directories build (standard configuration) and build-sd (used to build the SD card image version).

9. The previous step has created the build directory in which we define the build configuration parameters. The following configuration steps are common between docker and native build system since we edit mostlikely the configuration file from inside the host system.

## Configure the build system using your native host system

1. **Install the required packages** to use Yocto as described on the [Yocto required packages page](https://www.yoctoproject.org/docs/2.5/ref-manual/ref-manual.html#required-packages-for-the-host-development-system).

   * Ubuntu and Debian<br />
      ```shell
      sudo apt-get install gawk wget git-core diffstat unzip texinfo gcc-multilib \
      build-essential chrpath socat cpio python python3 python3-pip python3-pexpect \
      xz-utils debianutils iputils-ping
      ```
   * Fedora<br />
      ```shell
      sudo dnf install gawk make wget tar bzip2 gzip python3 unzip perl patch \
      diffutils diffstat git cpp gcc gcc-c++ glibc-devel texinfo chrpath \
      ccache perl-Data-Dumper perl-Text-ParseWords perl-Thread-Queue perl-bignum socat \
      python3-pexpect findutils which file cpio python python3-pip xz
      ```
2. Enter the poky directory to configure the build system
   ```shell
   $ cd lorix-os # if not already there
   $ cd poky
   ```
3. **Initialize the build directory**
   ```shell
   $ source oe-init-build-env
   ```
   This will create the build directory in which all the work will be done. You can also have alternative build directories with different configurations or different machines.
   To do so, you can create another build directory with a different name as follow:
   ```shell
   $ source oe-init-build-env build-alt-name
   ```
   > **Note:** For example, you could have the directories build (standard configuration) and build-sd (used to build the SD card image version).

## LORIX One's Yocto OS distribution configuration

The following setup has to be done only once and can be passed for the next build however, some of the configuration parameters described in this section can be changed following your needs. For example, the machine could be changed from lorix-one to lorix-one-512 or the atomic mender update subsystem could be enabled.

> **Note:** The descriptions here are **for both native and docker build system**. It will be described of each version when needed but assumed by default to be done from the native host system.<br/>
> In addition, since the Docker container is only used to compile the Yocto image, we will mostly working in the native system (linked to the Docker container) when we need to edit or configure a file.

1. **Copy default configuration files** from the lorix-os/tools directory:
   ```shell
      $ cd lorix-os
      $ cp tools/configs/local.conf poky/build/conf
      $ cp tools/configs/bblayers.conf poky/build/conf
   ```

2. **Customize default configuration** of the local.conf file:

   The default local.conf contains the following configuration:
   ```python
   # Standard LORIX OS inheritances
   INHERIT += "wifx-global"
   INHERIT += "mender-full-ubi"
   INHERIT += "mender-standalone"

   # LORIX OS distribution
   DISTRO = "lorix-os"

   # Default machine
   MACHINE ?= "lorix-one-256"
   #MACHINE ?= "lorix-one-512"

   # Download and sstate directory (ajusted with yocto:ubuntu-18.04 docker image)
   DL_DIR ?= "/yocto/downloads"
   SSTATE_DIR ?= "/yocto/sstate-${MACHINE}"

   # ENABLE_BINARY_LOCALE_GENERATION controls the generation of binary locale
   # packages at build time using qemu-native. Disabling it (by setting it to 0)
   # will save some build time at the expense of breaking i18n on devices with
   # less than 128MB RAM.
   ENABLE_BINARY_LOCALE_GENERATION = "1"

   # Set GLIBC_GENERATE_LOCALES to the locales you wish to generate should you not
   # wish to perform the time-consuming step of generating all LIBC locales.
   # NOTE: If removing en_US.UTF-8 you will also need to uncomment, and set
   # appropriate value for IMAGE_LINGUAS.
   # WARNING: this may break localisation!
   GLIBC_GENERATE_LOCALES = "en_US.UTF-8"
   IMAGE_LINGUAS ?= "en-us"

   PACKAGE_CLASSES ?= "package_ipk"

   EXTRA_IMAGE_FEATURES ?= "debug-tweaks"
   USER_CLASSES ?= "buildstats image-mklibs image-prelink"
   # By default disable interactive patch resolution (tasks will just fail instead):
   PATCHRESOLVE = "noop"

   #
   # Disk Space Monitoring during the build
   #
   # Monitor the disk space during the build. If there is less that 1GB of space or less
   # than 100K inodes in any key build location (TMPDIR, DL_DIR, SSTATE_DIR), gracefully
   # shutdown the build. If there is less that 100MB or 1K inodes, perform a hard abort
   # of the build. The reason for this is that running completely out of space can corrupt
   # files and damages the build in ways which may not be easily recoverable.
   # It's necesary to monitor /tmp, if there is no space left the build will fail
   # with very exotic errors.
   BB_DISKMON_DIRS ??= "\
      STOPTASKS,${TMPDIR},1G,100K \
      STOPTASKS,${DL_DIR},1G,100K \
      STOPTASKS,${SSTATE_DIR},1G,100K \
      STOPTASKS,/tmp,100M,100K \
      ABORT,${TMPDIR},100M,1K \
      ABORT,${DL_DIR},100M,1K \
      ABORT,${SSTATE_DIR},100M,1K \
      ABORT,/tmp,10M,1K"

   # CONF_VERSION is increased each time build/conf/ changes incompatibly and is used to
   # track the version of this file when it was generated. This can safely be ignored if
   # this doesn't mean anything to you.
   CONF_VERSION = "1"

   INHERIT += "buildhistory"
   BUILDHISTORY_COMMIT = "1"
   ```

   **The practical parameters to change are:**

   * The machine the image is built for
      - lorix-one-256
      - lorix-one-512
   * The download directory (DL_DIR) and defined by default as /yocto/downloads to match the docker container previously configured
   * The sstate cache directory (SSTATE_DIR) defined by default as /yocto/sstate-<machine> (for example /yocto/sstate-lorix-one-256)


   > **Note:** Machine names have changed and have been simplified. The whole recipes match (or should) for this new OS release.

   > **Note:** The directory should not be accessed by multiple running instance of Yocto at the same time and thus can not be really shared for multiple user. The advantage is really for incremental work and some modification inside the LORIX OS recipes could need a almost conplete system generation. If you work on two very different flavour of LORIX OS, it's better to have two different sstate directory.

   Useful to create depencies graph and more details about packages size however is longer to compile and takes more space.
   ```
   INHERIT += "buildhistory"
   BUILDHISTORY_COMMIT = "1"
   ```
   To remove work files after the build system has finished and reduce the overall system size, activate the option with this line in end of file:
   ```
   INHERIT += "rm_work"
   ```

3. Build the Wifx standard image
   ```shell
   $ bitbake wifx-image-os
   ```
   Typical bitbake output:
   ```
   Build Configuration:
   BB_VERSION           = "1.38.0"
   BUILD_SYS            = "x86_64-linux"
   NATIVELSBSTRING      = "universal"
   TARGET_SYS           = "arm-lorixos-linux-gnueabi"
   MACHINE              = "lorix-one-256"
   DISTRO               = "lorix-os"
   DISTRO_VERSION       = "0.3.0"
   TUNE_FEATURES        = "arm armv7a vfp thumb neon callconvention-hard cortexa5"
   TARGET_FPU           = "hard"
   meta
   meta-poky
   meta-yocto-bsp       = "sumo:cbb677e9a09d5dad34404a851f7c23aeb5122465"
   meta-oe
   meta-networking
   meta-python
   meta-multimedia      = "sumo:8760facba1bceb299b3613b8955621ddaa3d4c3f"
   meta-wifx            = "sumo:7b01151b5be4a58c78b63d4678fe662979d56354"
   meta-wifx-lorix      = "sumo:a501c1fbb609e792adedc993863c7ca2d0ba52c9"
   meta-wifx-openrc     = "sumo:02c566edb02669956529eab91ad5184780216201"
   meta-wifx-mender     = "sumo:5e88cb66d98851c662554efceabd081fbe969eef"
   ```
   Maintainers: Wifx's R&D team <red@wifx.net>

4. **Exploit the build result** from the host system

   Since we have a volume mounted for between the host and the docker container where the LORIX OS workspace directory is located, the build result can be found from inside the container but also from outside.

   If you followed our directory volume convention:
     * From inside the container<br/>
       the result images will be found in `/home/build/poky/build/tmp/deploy/images/<machine>`
     * From outside the container<br />
       the result images will be found in `/home/you/devel/lorix-os/poky/build/tmp/deploy/images/<machine>`


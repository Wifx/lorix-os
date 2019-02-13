# This workspace provides all the material needed to build a Yocto distribution for the LORIX One Wifx's gateway

## Supported machine
* LORIX One products (256 and 512MB versions)

## Sources

* wifx-yocto-lorix-workspace<br />
  URI: [https://git.wifx.net/wifx/next/wifx-yocto-lorix-workspace.git](https://git.wifx.net/wifx/next/wifx-yocto-lorix-workspace.git)<br />
  Branch: sumo

## Dependencies
This build workspace depends on:

* **meta-wifx**<br />
  URI: [https://git.wifx.net/wifx/next/meta-wifx.git](https://git.wifx.net/wifx/next/meta-wifx.git)<br />
  Branch: sumo<br />
  Status: Important work in progress, not stable and highly subject to huge modification

* **meta-wifx-lorix**<br />
  URI: [https://git.wifx.net/wifx/next/meta-wifx-lorix.git](https://git.wifx.net/wifx/next/meta-wifx-lorix.git)<br />
  Branch: sumo<br />
  Status: Important work in progress, not stable and highly subject to huge modification

* **meta-wifx-mender**<br />
  URI: [https://git.wifx.net/wifx/next/meta-wifx-mender.git](https://git.wifx.net/wifx/next/meta-wifx-mender.git)<br />
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
$ git clone --recursive -j8 https://git.wifx.net/wifx/next/wifx-yocto-lorix-workspace.git
$ cd wifx-yocto-lorix-workspace
$ git submodule update --init
$ git submodule foreach -q --recursive 'git checkout $(git config -f $toplevel/.gitmodules submodule.$name.branch || echo master)'
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
2. Go inside the right Docker file directory in the workspace repository:<br />
   ```shell
   $ cd work_directory/wifx-yocto-lorix-workspace/tools/docker/yocto-ubuntu-18.04
   ```
3. Retrieve your current Linux user ID:
   ```shell
   $ id -u
   1000
   ```
   This ID is 1000 by default for the first user however, it can't be different sometime. It's important to not just let 1000 at the next step.
4. **Modify the user ID in the file Dockerfile** of the current directory at the user creation line:
   ```docker
   # Create a non-root user that will perform the actual build
   RUN id build 2>/dev/null || useradd --uid [previous step found UID] --create-home build  
   ```
   > **Note:** Since the files are shared between your native host and the Docker container in read and write mode, **it is important to keep the same user ID between both systems**. It would be however more difficult to use the same Docker container for multiple native system user account (which will not be discussed here).
5. **Create the Docker image** by building this Dockerfile from its directory:
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
   
   In addition, this container can be easily shared among customers or colleagues.
6. **Start the Docker container** and understand the directories mapping<br />
   We usually edit and modify the Yocto's configuration files (or package recipes) from the build host OS and keep the Docker container to only build the final image. 

   To make the nexts explaination more easy to understand, we will define some values:
   *  **\<host dir\>**<br />
      The directory ```wifx-yocto-lorix-workspace``` containing your workspace on your host system. This directory is variable and depends really on your own configuration, for example ```/home/you/devel/wifx-yocto-lorix-workspace```
   *  **\<docker dir\>**<br />
      The directory in the Docker container where should be binded the **\<host directory\>**. This directory is fixed and should ideally ```/home/build```. This is where you are located when you start the Docker container.

   That being said, we need to start the yocto:ubuntu-18.04 Docker container:
   ```shell
   $ sudo docker run --rm -it -v <host dir>:<docker dir> yocto:ubuntu-18.04
   ```
   or
   ```shell
   $ sudo docker run --rm -it -v <host dir>:/home/build yocto:ubuntu-18.04
   build@dfe8e4eeb96f:~$ # you are now inside the container
   ```
   The ```--rm``` argument is used to make the container as temporary and to delete it when we quit. The ```-it``` stands for interactive (i) and tty (t) to open a terminal directly connecting the host therminal to the container's internal terminal.
   > **Note:** This command will be used each time you will need to launch the Yocto building Docker container.
7. **Create the initial Yocto build directory**<br />

## Configure the build system using your native host system

1. Install the required packages to use Yocto as described on the [Yocto required packages page](https://www.yoctoproject.org/docs/2.5/ref-manual/ref-manual.html#required-packages-for-the-host-development-system).

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
   $ cd wifx-yocto-lorix-workspace # if not already there
   $ cd poky
   ```
3. Initialize the build directory
   ```shell
   $ source oe-init-build-env
   ```
   This will create the build directory in which all the work will be done. You can also have alternative build directories with different configurations or different machines.
   To do so, you can create the build directory with a different name as follow:
   ```shell
   $ source oe-init-build-env build-alt-name
   ```
   > **Note:** For example, you could have the directories build (standard configuration) and build-sd (used to build the SD card image version).
4. 

4. **Create the initial Yocto build directory**<br />


## LORIX One's Yocto OS distribution configuration

The following setup has to be done only once and can be passed for the next build however, some of the configuration parameters described in this section can be changed following your need. For example, the machine could be changed from lorix-one to lorix-one-512 or to the atomic mender update subsystem could be enabled. 

> **Note:** The descriptions here are **for both native and docker build OS**. It will be described of each version when needed. 
> In addition, since the Docker container is only used to compile the Yocto image, we will mostly working in the native system (linked to the Docker container) when we need to edit or configure the Yocto system.








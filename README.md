# This workspace provides all the material needed to build a Yocto distribution for the LORIX One Wifx's gateway

## Supported machine
* LORIX One products (256 and 512MB versions)

## Sources

* wifx-yocto-lorix-workspace</br>
  URI: [https://git.wifx.net/wifx/next/wifx-yocto-lorix-workspace.git](https://git.wifx.net/wifx/next/wifx-yocto-lorix-workspace.git)</br>
  Branch: sumo

## Dependencies
This build workspace depends on:

* **meta-wifx**</br>
  URI: [https://git.wifx.net/wifx/next/meta-wifx.git](https://git.wifx.net/wifx/next/meta-wifx.git)</br>
  Branch: sumo</br>
  Status: Important work in progress, not stable and highly subject to huge modification

* **meta-wifx-lorix**</br>
  URI: [https://git.wifx.net/wifx/next/meta-wifx-lorix.git](https://git.wifx.net/wifx/next/meta-wifx-lorix.git)</br>
  Branch: sumo</br>
  Status: Important work in progress, not stable and highly subject to huge modification

* **meta-wifx-mender**</br>
  URI: [https://git.wifx.net/wifx/next/meta-wifx-mender.git](https://git.wifx.net/wifx/next/meta-wifx-mender.git)</br>
  Branch: sumo</br>
  Status: Important work in progress, not stable and highly subject to huge modification

* **meta-openembedded**</br>
  URI: [git://git.openembedded.org/meta-openembedded](git://git.openembedded.org/meta-openembedded)</br>
  Branch: sumo</br>
  Status: Stable

* **poky**</br>
  URI: [git://git.yoctoproject.org/poky](git://git.yoctoproject.org/poky)</br>
  Branch: sumo</br>
  Status: Stable

## Requirement
This workspace is known to work on Ubuntu 18.04LTS. To garantee a stable and known to work environnement, it is strongly advised to use the Dockerfile provided in this workspace as explained below.

## Download and setup procedure

1. Download the workspace using git</br>
    ```
    $ cd work_directory
    $ git clone --recursive -j8 https://git.wifx.net/wifx/next/wifx-yocto-lorix-workspace.git
    $ git submodule update --init
    $ git submodule foreach -q --recursive 'git checkout $(git config -f $toplevel/.gitmodules submodule.$name.branch || echo master)'
    ```
    > **Note:** The repositories are subject to change when they will be made publicly available.

    Display all the submodule status when git status is invokey in this repo:
    ```
    git config --global status.submoduleSummary true
    ```
    > **Note:** Affect globally your git settings and then other git repo containing submodules

2. Choose between Docker (strongly adviced) or native build system
   1. Docker</br>
   TODO
   2. Native system
      1. Install the required packages to use Yocto as described on the [Yocto required packages page](https://www.yoctoproject.org/docs/2.5/ref-manual/ref-manual.html#required-packages-for-the-host-development-system).

          * Ubuntu and Debian</br>
            ```
            sudo apt-get install gawk wget git-core diffstat unzip texinfo gcc-multilib \
            build-essential chrpath socat cpio python python3 python3-pip python3-pexpect \
            xz-utils debianutils iputils-ping
            ```
          * Fedora</br>
            ```
            sudo dnf install gawk make wget tar bzip2 gzip python3 unzip perl patch \
            diffutils diffstat git cpp gcc gcc-c++ glibc-devel texinfo chrpath \
            ccache perl-Data-Dumper perl-Text-ParseWords perl-Thread-Queue perl-bignum socat \
            python3-pexpect findutils which file cpio python python3-pip xz
            ```
3. 




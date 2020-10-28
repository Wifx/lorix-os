# Build the Docker build host image

1. **Go inside the right Docker file directory** in the workspace repository:<br />
   ```shell
   $ cd lorix-os/tools/docker/yocto-ubuntu-20.04
   ```

2. **Create the Docker image** by building this Dockerfile from its directory:
   ```shell
   $ docker build -t wifx/yocto:ubuntu-20.04 .
   Sending build context to Docker daemon  3.584kB
   Step 1/18 : FROM ubuntu:20.04
    ---> cd6d8154f1e1
   Step 2/18 : ENV DEBIAN_FRONTENV noninteractive
   [...]
   Successfully built 2d5d9da4c7b1
   Successfully tagged wifx/yocto:ubuntu-20.04
   ```
   This Docker image is now available on your system and allows to create easily a container supporting the build of the Yocto system. Based on this system, you are always sure:
     * That the container is clean when you use it since we will use temporary container (deleted when you exit from it)
     * That the container contains all the packages you need to make Bitbake build system and Yocto working well

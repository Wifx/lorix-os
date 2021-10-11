# LORIX OS SDK Docker image

Dockerfile for a LORIX OS SDK Docker image. This images allows anyone to easily build software targettting the Wifx LORIX products.

## Image description

The image is based on Ubuntu 20.10 LTS and contains:

- Build essentials
- The LORIX OS toolchain
  - C compiler
  - Included libraries and their headers

## Versions

The tag name corresponds to the version of LORIX OS the toolchain is from.

## Use

Start a container in interactive mode:

```bash
docker run -it -v <project-path>:/root wifx/lorix-os-sdk
```

*The ```-v``` argument mounts a volume between the host filesystem and the system running in the container, so you can access your files from the container*

The environemnt is automatically prepared for the 'arm-lorixos-linux-gnueabi' toolchain.

Build your project:

```bash
arm-lorixos-linux-gnueabi-gcc
make
...
```

## Build

To create a new version of the SDK:

1. Get a toolchain installer
2. Build the image

### Get a toolchain

Either build it from the build system with the `wifx-image-sdk -c populate_sdk` recipe or download it from https://download.wifx.net/lorix-os/ with the download.sh script.

```bash
./download.sh 1.3.3
```

Copy the installer shell script to the same location than the Dockerfile and call id sdk-installer.sh.

### Build the image

```bash
docker build -t wifx/lorix-os-sdk:<version> .
```

# LORIX OS SDK Docker image

Dockerfile for a LORIX OS SDK Docker image. This images allows anyone to easily build software targettting the Wifx LORIX products.

## Image description

The image is based on Ubuntu 18.04 LTS and contains:

- Build essentials
- The LORIX OS toolchain
  - C compiler
  - Included libraries and their headers
- The GO 1.13 compiler

## Versions

The tag name corresponds to the version of LORIX OS the toolchain is from.

The version of the GO compiler corresponds to the version used in the corresponding LORIX OS version.

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

To create a new version of the SDK, edit the docker file and edit the following variables:

```bash
GO_VERSION=<the version of the GO compiler that will be installed>
```

The assets are downloaded from the Internet (Wifx downloads and GO binary repository).

Build the image with:

```bash
docker build -t wifx/lorix-os-sdk:1.3.0 --build-arg GO_VERSION=1.15 --build-arg LORIXOS_TOOLCHAIN_VERSION=1.3.0 .
```

Replace LORIXOS_TOOLCHAIN_VERSION with what you defined in the Dockerfile.

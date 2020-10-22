# Prepare your native host system for a Yocto build with Docker

In this configuration, the Yocto build will be done inside a Docker container. This container is based on an image that contains all the required dependencies.

## Install Docker CE 

Install Docker CE on your Linux based system as explained in the Docker's documentation:
   1. [Ubuntu](https://docs.docker.com/install/linux/docker-ce/ubuntu/)
   2. [Debian](https://docs.docker.com/install/linux/docker-ce/debian/)
   3. [Fedora](https://docs.docker.com/install/linux/docker-ce/fedora/)

## Get the build container Docker image

You can get the image in two different ways:
    1. Pull it from the Wifx Docker registry
    2. Build it from the lorix-os repository you cloned

We recommand pulling the image from the Wifx Docker registry.

### Pull the image

Pull the image with:
```
$ docker pull wifx/yocto:ubuntu-20.04
```

### Build the image

Please refer to [the Docker image build page](DOCKER-BUILD.md).

## Test the image

You can test the image by running it with:
```
$ docker run -it wifx/yocto:ubuntu-20.04
```

You should land into the container. It will just display a shell:
```
build@6337712a76a6:~$
```

Exit the container for now with:
```
$ exit
```

## Create the yocto user

The Yocto build process will be done inside the Docker container and thus, files generated inside and shared through a volume should also be readable from outside. An easy solution is to create a user with the same ID inside the container and outside (inside the Docker host).

The current Docker image create a user namely `build` with the user ID (uid) 5000. You then need to create a user in your host system with the same uid (user name doesn't matter). In our case, we create this user the with name `yocto` and assign a new password:

```shell
$ sudo useradd -u 5000 yocto
$ sudo passwd yocto
New password:
Retype new password:
passwd: all authentication tokens updated successfully.
```

TODO: add the current user to the yocto group

You can impersonate this user temporary using the `su` command:
```shell
user1@host $ su yocto
Password:
yocto@host $ (you are now yocto)
yocto@host $ exit
user1@host $ (you are not anymore yocto)
```

## Optional: Create a volume for the Yocto cache

Since Yocto generate a lot of files and especially a cache which permits to build "incrementaly" very quickly, it's really convenient to keep this cache outside of the container in order to reuse it even if the container is closed or destroyed. It's also very convenient to share the download directory of Yocto among multiple container (in team for example).

This volume must be owned by the yocto user in order to be writable from inside the container.
```shell
$ sudo mkdir -p /home/username/lorix-os-cache
$ sudo chown yocto:yocto /home/username/lorix-os-cache
```

## Run the Docker container for a Yocto build

The above steps should be done only once by host machine. Once setup, you can run the container by [reading this guide](DOCKER-RUN.md).

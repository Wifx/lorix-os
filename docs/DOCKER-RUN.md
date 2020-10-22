# Run the Docker container for a Yocto build

Run the Docker image with a binding on the lorix-os directory:
```shell
$ sudo docker run -it --name lorix-os-bs -v /home/username/lorix-os:/home/build wifx/yocto:ubuntu-20.04
build@dfe8e4eeb96f:~$ # You are now inside the container, in the lorix-os folder on the host containing the LORIX OS sources
```

When the container is started, the current directory is `/home/build`. This directory is bound to `/home/username/lorix-os`. This means that `build@dfe8e4eeb96f:~$` is actually the 'workspace' directory.

> **Important:** Outside the container (on the host), you are using your user. Inside the container, you are using the yocto user. **Always** edit the source files of `lorix-os` from the host system (outside the container). You should never edit the files built by yocto located at `lorix-os/poky/build`.

> **Note:** The ```-it``` stands for interactive (i) and tty (t) to open a terminal directly connecting the host therminal to the container's internal terminal.

> **Note:** If the container already exists, you will get an error. Attach to the existing container instead of running a new one.

The build cache is stored inside the container. When you exit the container, it still exists. If the container is deleted, the cache is lost.

To attach to an existing container, run:
```shell
$ docker exec -it lorix-os-bs
```

## Persistant cache

If you want to make the cache persistant when the container is removed or when you run a new container, bind the cache folder to a names volume:
```shell
$ sudo docker run -it --name lorix-os-bs -v /home/username/lorix-os:/home/build -v lorix-os-yocto-cache:/yocto wifx/yocto:ubuntu-20.04
```

> **Note:** The cache should not be accessed by multiple instances of Yocto at the same time.

> **Note:** You can also bind the cache volume to a defined location on your filesystem instead of a named volume.


## Automatically remove the container

If you add the ```--rm``` argument, the container will be automatically deleted on exit:
```shell
$ sudo docker run -it --name lorix-os-bs --rm -v /home/username/lorix-os:/home/build wifx/yocto:ubuntu-20.04
```

> **Note:** When the container is deleted, the cache is deleted. Source files and build result are not deleted as they are provided through the volume and are therefore not stored inside the container.

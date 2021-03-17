# Run the Docker container for a Yocto build

Run the Docker image with a binding on the lorix-os directory:
```shell
$ docker run -it --name lorix-os-bs -v ~/lorix-os:/home/yocto/lorix-os wifx/yocto:ubuntu-20.04
yocto@dfe8e4eeb96f:~$ cd lorix-os
yocto@dfe8e4eeb96f:~/lorix-os$ # You are now inside the container, in the lorix-os folder on the host containing the LORIX OS sources
```

When the container is started, the current directory is `/home/yocto`. `/home/yocto/lorix-os` is bound to `~/lorix-os`. This means that after `cd lorix-os` you are in the 'workspace' directory.

> **Important:** Outside the container (on the host), you are using your user. Inside the container, you are using the yocto user. **Always** edit the source files of `lorix-os` from the host system (outside the container). You should never edit the files built by yocto located at `lorix-os/poky/build`.

> **Note:** The ```-it``` stands for interactive (i) and tty (t) to open a terminal directly connecting the host therminal to the container's internal terminal.

> **Note:** If the container is already running, you will get an error. Attach to the existing container instead of running a new one.
> 
> To attach a running container:
> ```shell
> $ docker exec -it lorix-os-bs bash
> yocto@dfe8e4eeb96f:~$ cd lorix-os
> yocto@dfe8e4eeb96f:~/lorix-os$
> ```
> If the container is not running, use the docker start command below.

The build cache is stored inside the container. When you exit the container, it's stopped but it still exists.

To start an existing container, run:
```shell
$ docker start -i lorix-os-bs
```

To remove the container, run:
```shell
$ docker rm lorix-os-bs
```

> **Note:** If the container is deleted, the cache is lost.

## Persistent cache

If you want to make the cache persistent when the container is removed or when you run a new container, bind the cache folder to a names volume:
```shell
$ docker run -it --name lorix-os-bs -v ~/lorix-os:/home/yocto/lorix-os -v lorix-os-yocto-cache:/yocto wifx/yocto:ubuntu-20.04
```

> **Note:** The cache should not be accessed by multiple instances of Yocto at the same time.

> **Note:** The cache can be removed with `docker volume rm lorix-os-yocto-cache` (e.g. to free space).

> **Note:** You can also bind the cache volume to a defined location on your filesystem instead of a named volume with e.g. `-v ~/lorix-os-cache:/yocto`.


## Automatically remove the container

If you add the ```--rm``` argument, the container will be automatically deleted on exit:
```shell
$ docker run -it --name lorix-os-bs --rm -v ~/lorix-os:/home/yocto/lorix-os wifx/yocto:ubuntu-20.04
```

> **Note:** When the container is deleted, the cache is deleted. Source files and build result are not deleted as they are provided through the volume and are therefore not stored inside the container.

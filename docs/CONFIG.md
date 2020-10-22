# LORIX OS Yocto configuration

The following setup has to be done only once and can be passed for the next build however, some of the configuration parameters described in this section can be changed following your needs. For example, the machine could be changed from lorix-one to lorix-one-512 or the atomic mender update subsystem could be enabled.

> **Note:** The descriptions here are **for both native and docker build system**. It will be described of each version when needed but assumed by default to be done from the native host system.<br/>
> In addition, since the Docker container is only used to compile the Yocto image, we will mostly working in the native system (linked to the Docker container) when we need to edit or configure a file.

2. **Customize default configuration** of the local.conf file:

   **The main options you are likely to change are:**

   * MACHINE: The machine the image is built for
      - lorix-one-256
      - lorix-one-512


   Useful to create depencies graph and more details about packages size however is longer to compile and takes more space.
   ```
   INHERIT += "buildhistory"
   BUILDHISTORY_COMMIT = "1"
   ```
   To remove work files after the build system has finished and reduce the overall system size, activate the option with this line in end of file:
   ```
   INHERIT += "rm_work"
   ```

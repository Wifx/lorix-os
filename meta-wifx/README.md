## Supported machine
* LORIX One products (256 and 512MB versions)

## Sources

* meta-wifx<br />
  URI: [https://git.wifx.net/wifx/next/meta-wifx.git](https://git.wifx.net/wifx/next/meta-wifx.git)<br />
  Branch: sumo

## Status
Stable but under active developpment

## Notes
* Provides the foundation for the Wifx OS generation for the LORIX family. This meta tries to have as less as possible dependencies on hardware and focuses on general distribion aspects.

## Classes
* Provides the following classes:
  * **wifx-dataimg.bbclass**<br/>
    Used for the creation of the data directory based image used to build the data UBI volume
  * **wifx-ubimg.bbclass**<br/>
    Used for the creation of the root directory based image used to build the rootfs UBI volume<br/>
    > **Note:** Single rootfs based with data overlay
  * **wifx-setup.bbclass**<br/>
    Include **wifx-dataimg** and **wifx-ubimg**, directly included by the meta-wifx in **conf/layer.conf**
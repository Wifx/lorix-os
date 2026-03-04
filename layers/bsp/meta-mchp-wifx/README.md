# Support for Wifx's products based on Microchip SAMA5D4x CPU
Provides all the material required to build packages for Wifx's products based on Microchip CPU:
* First stage bootloader (at91bootstrap)
* Second stage bootloader (u-boot)
* Kernel
* All others packages coupled to this particular hardware

## Supported hardware
* sama5d4-wifx<br />
  Defines a generic machine from Wifx based on the SAMA5D4 CPU

## Dependencies

This meta depends on:

* **meta-atmel**<br />
  URI: [https://github.com/linux4sam/meta-atmel.git](https://github.com/linux4sam/meta-atmel.git)<br />
  Branch: zeus<br />

## License
See attached LICENSE file

## Notes
* This meta is part of the LORIX OS workspace and is not intented to be built or used outside of it.
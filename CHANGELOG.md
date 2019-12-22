# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.0] - 2019-12-22

### Changed

- Update manager to v0.4.1
- Update manager-ui to v0.4.1
- Update pmonitor to v0.4.0
- [LOR-214] - Disable root access login
- [LOR-220] - Disable WPF channel deletion at first boot
- [LOR-221] - Remove the WPF TTN config
- [LOR-225] - Remove nmtui in default image
- [LOR-234] - Change base-files-lorix to base-files-machine
- [LOR-236] - Init SSH daemon key in post-install script instead of pre-start init script
- [LOR-247] - Change wifx-image-minimal to wifx-image-os
- [LOR-227] - Remove LOROS from kernel (/sys/class/loros to /sys/class/product)
- [LOR-228] - Update preinit scripts for new kernel sysfs entry
- [LOR-229] - Change distro name from wifx-loros to lorix-os
- [LOR-230] - Change base-files-loros to base-files-os
- [LOR-231] - Change all package-group-loros* to package-group-os*
- [LOR-232] - Change /var/cache/loros/os-update to /var/cache/os/upgrade-info
- [LOR-233] - Remove LOROS from system machine functions scripts
- [LOR-237] - Remove remaining LOROS occurence in various text files
- [LOR-238] - Update CI to remove LOROS
- [LOR-239] - Remove LOROS in motd
- [LOR-242] - Remove all assets related to LOROS in web front download server
- [LOR-249] - Change repo URLs
- [LOR-218] - Move all forwarders binary to /opt
- [LOR-226] - Make system OS name agnostic
- [LOR-244] - Refactor workspace rev hash and date
- [LOR-246] - Generate image name based on workspace rev hash

### Fixed

- [LOR-187] - password prompt with SSH is really long to pop
- [LOR-213] - Avahi problem at first boot
- [LOR-224] - Semtech packet forwarder has package and package-slit data in /etc/lpf/configs
- [LOR-240] - /etc/default/volatiles/00_core is provided by initscripts and openrc-base-files recipes
- [LOR-241] - Mender artifact name is wrong (workspace_hash missing)
- [LOR-248] - Fix machine information in web interface
- [LOR-243] - Fix OS update information in motd (maybe related to manager)

## [0.3.0] - 2019-12-12

### Added

- [LOR-183] - Publish the release metadata file with the release during the publish process
- [LOR-185] - Report update status through CLI
- [LOR-188] - Add revision in the name of the build-system assets
- [LOR-193] - Add NetworkManager 1.18.4 support

### Changed

- [LOR-192] - Move udev binary db from /etc/udev/hwdb.bin to /lib/udev/hwdb.bin to simplify migration process
- [LOR-194] - Remove useless udev hardware configuration files from build
- [LOR-200] - Upgrade Go to 1.13
- [LOR-209] - Change rootfs[A|B]/data proportion size for 512MB version

### Fixed

- [LOR-181] - Set default pmonitor services files to have standard yaml format
- [LOR-182] - Files size is not computed in the release metadata file
- [LOR-184] - Compile ChirpStack gateway bridge with a version
- [LOR-202] - Correct pmonitor socket path to /dev/shm/pmonitor instead of /tmp/pmonitor

## [0.2.0-beta] - 2019-11-17

### Added

- [LOR-174] - Generate releases metadata files
- [LOR-178] - Add tree command in mainline image 
- [LOR-93] - Add lora-gateway-bridge pmonitor support
- [LOR-97] - lora-gateway-bridge yocto recipe (from sources)
- [LOR-162] - Update a file for dynamic motd from the manager for update notification
- [LOR-170] - /etc overlay architecture (yocto)
- [LOR-171] - Simple /etc migration
- [LOR-176] - Support factory reset rollback in preinit during pending update
- [LOR-91] - LoRaServer integration
- [LOR-99] - Add support for Mender 2.0
- [LOR-107] - LORIOT packet forwarder integration
- [LOR-168] - Atomic configuration migration (/etc overlay)

### Changed

- [LOR-166] - Turn off the status led at shutdown
- [LOR-163] - Update the dynamic motd with the release information notification

### Fixed

- [LOR-115] - NetworkManager doesn't get DHCP sometimes on first boot
- [LOR-167] - watchdog : cannot set timeout 60 (errno = 22 = 'Invalid argument')
- [LOR-177] - new /etc overlay architecture is not supported correctly by Mender
- [LOR-180] - First boot status LED has been broken by new /etc/overlay implementation (LOR-177)

## [0.1.0-beta] - 2019-10-02

### Added

- Add legacy SPI device support
- Added LORIOT packet forwarder
- dnsmasq support
- Added pmonitor v0.2.1
- Added pvisor v0.1.2
- Added pmcli v0.1.0

### Changed

- Update manager to v0.1.1
- Update manager-ui to v0.1.1
- No LoRa forwarder running by default
- The hostname is now 'lorix-one-xxxxxx' whre xxxxxx are the 6 last chars of the mac address

## [0.0.3-alpha] - 2019-09-04

### Added

- libpam
- Dynamic motd generation (using modified libpam)
- prerm/postinst OPKG state logic scripts for OpenRC init scripts
- Support for volatiles directories/symlinks/files on boot
- cron daemon OpenRC support
- NetworkManager DNS caching with dnsmasq
- Integration of manager v0.0.3
- Integration of manager-gui v0.0.1-beta.1
- Distro codename in os-release file

### Changed

- Default user changed from root without password to admin/lorix4u
- OpenRC init scripts timeout from 60 to 120 seconds

### Removed

- nano dependency on file (the Linux tool) and file itself to reduce image size

### Fixed

- pmonitor handles now SIGTERM and SIGINT correctly
- Bad symlink for wpf to wifx-packet-forwarder binary

## [0.0.2-beta.1] - 2019-08-09

### Added

- Status LED blinking to show first init work in progress status
- Hardware watchdog support
- Cache and sysfs support for board detection utils
- Shell color (for ls for example)
- SX1301 reset OpenRC script
- Integration of wifx-packet-forwarder v4.0.0-beta.2
- Integration of pvisor v0.0.1-beta
- Integration of pmonitor v0.0.1-beta
- Integration of lora-basic-station v2.0.3
- Integration of lora-gateway-bridge v3.0.1

### Changed

- Updated motd with LORIX OS logo and with release information (build date, workspace hash)

## [0.0.1-beta.1] - 2019-07-10

### Added

- nmtui configuration util to configure more easily the NetworkManager with CLI
- OS unified manager including web interface (still needs work like certificate generation)<br/>
Including OpenRC boot script with supervisor management (respawn auto)
- Optimized wimg release image size (almost divided by 2)
- Created default NetworkManager connection configuration (DHCP by default with 192.168.8.8 static fallback)
- Distro workspace build datetime into os-release file

### Changed

- Removed 1s u-boot boot time delay

### Fixed

- UBI missing PEBs for bad PEB handling

## [0.0.1-beta] - 2019-07-03

### Added

- OS release information in file `<distro>/release.conf`
- OPKG packages manager follows this release information

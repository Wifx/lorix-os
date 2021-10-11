# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.4.0] - Unreleased

### Added

- [LOR-473] Add sftp support (fix sshd sftp configuration)
- [LOR-481] Supervise critical system daemons
- [LOR-149] Provide product serial through sysfs

### Changed

- [LOR-487] Update ChirpStack Gateway Bridge to v3.13
- [LOR-469] Upgrade go compiler to v1.16
- [LOR-470] Upgrade nodejs-native to v12
- [LOR-471] Update mender-artifact to 3.5.2
- [LOR-472] Upgrade manager to 0.12
- [LOR-484] Update pmonitor to v0.9.0
- [LOR-458] Update Linux kernel to 5.4.104

### Fixed

- [LOR-451] NetworkManager chrony dispatcher warning

## [1.3.3] - 2021-08-25

### Changed

- [LOR-474] Restore FSB2 as default frequency plan for US region

## [1.3.2] - 2021-07-29

### Changed

- [LOR-463] Update syslog-ng to 3.33.2 
- [LOR-464] Limit syslog maximal buffer size

## [1.3.1] - 2021-07-14

### Change

- [LOR-456] Replace SALB with SLUB

### Fix

- [LOR-455] Kernel memory leak in the slab

## [1.3.0] - 2021-05-11

### Added

- [LOR-445] Add LoRa concentrator reset script to the BasicStation configuration
- [LOR-426] Update the GPIO control system (add libgpio tools)
- [LOR-444] Enable standard cron directories (hourly, daily, weekly, monthly)
- [LOR-173] Restrict the size of /var/log

### Changed

- [LOR-389] Rename OpenRC service "reset-lgw" to "lora-concentrator"
- [LOR-439] Reset lora-concentrator with libgpio tools
- [LOR-422] Upgrade NetworkManager to 1.28.0
- [LOR-449] Upgrade pmonitor to v0.8 
- [LOR-450] Update ChirpStack Gateway Bridge to 3.10.0 
- [LOR-447]	Upgrade manager to v0.11

### Fixed


## [1.2.2] - 2021-02-18

### Changed

- [LOR-438] Upgrade Go to 1.14
- [LOR-435] Manager UI v0.10.1
- [LOR-436] Pvisor 0.3.1
- [LOR-437] Pmonitor v0.7.1

## [1.2.1] - 2020-12-08

### Fixed

- [LOR-431] SNMP init script is missing
- [LOR-432] Temporarilly remove crypto hardware acceleration (fixes some OpenVPN connection failures)

## [1.2.0] - 2020-10-28

### Added

- [LOR-413] Export RAM and NAND hardware info in sysfs machine driver
- [LOR-423] Add frequency plans variants for UDP Packet Forwarder (channels)

### Changed

- [LOR-313] Update Yocto to version Zeus
- [LOR-424] Manager v0.10

## [1.1.1] - 2020-09-03

### Changed

- [LOR-416] Manager GUI v0.9.2

### Fixed

- [LOR-415] Migrate fake GPS default value

## [1.1.0] - 2020-08-21

### Added

- [LOR-410] Add 3 and 5dBi antennas hardware files

### Changes

- [LOR-408] - Update UDP Packer Forwarder to v5.0.3
- [LOR-409] - Disable fake GPS report by default for UDP Packet Forwarder
- Update NetworkManager to 1.22.14
- Update Manager to v0.9

## [1.0.1] - 2020-06-24

### Added

- [LOR-399] Add migration to fix manager config dir migration bug

### Changed

- [LOR-397] - Add libidn2 and update curl to 7.66
- [LOR-400] - Manager v0.8.2

### Fixed

- [LOR-383] - Netif freeze, apply final patch to Linux kernel 4.19
- [LOR-398] - Manager config directory rights on migration

## [1.0.0] - 2020-06-12

This release consolidates rc.3 as the stable release.

## [1.0.0-rc.3] - 2020-06-12

### Changed

- [LOR-394] - BasicStation config migration : skip instead of abort in case of error
- [LOR-393] - Upgrade manager GUI to 0.8.2

## [1.0.0-rc.2] - 2020-06-10

### Changed

  - [LOR-384] - Update support mail address to support@iot.wifx.net
  - [LOR-392] - Upgrade manager to 0.8.1

### Fixed

  - [LOR-390] - The Basic Station has no valid conf after upgrade from 0.4.0 to 1.0.0

## [1.0.0-rc.1] - 2020-06-07

### Added

- Add pmcli bash completion
- [LOR-363] - Add net-snmp-server on std image, disabled on 256MB version. OpenRC init script not enabled by default.

### Changed

- [LOR-347] - The DHCP should ALWAYS try to connect
- [LOR-223] - Use pool.ntp.org as default NTP pool
- [LOR-360] - Rename the Wifx packet forwader to UDP Packet Forwarder
- Remove insane skip and improve OpenRC class
- [LOR-365] - Update NetworkManager to 1.22.10, NetworkManager-OpenVPN to 1.8.12
- [LOR-366] - NetworkManager: use internal DHCP client and remove rdep on dhclient
- [LOR-367] - NetworkManager: change con params to have IPv4 DHCP client always running
- [LOR-370] - Upgrade ChirpStack to v3.8.0
- Manager 0.8.0
- pmonitor / pmcli 0.6.0
- [PMON-72] [PMON-93] - pvisor 0.2.1 - Crash bug fix and great stability/performance improvement
- [PMON-100] - pvisor 0.2.2 - Stdout/stderr are not treated in real time
- [LOR-382] - Update Basic Station to 2.0.4-9-g3d5c686

## [0.6.0] - 23-04-2020

### Added

- [LOR-286] - iptables modules
- [LOR-297] - NetworkManager dispatcher for NTP (chrony)
- [LOR-287] - NetworkManager NTP server option (42) for DHCP

Upgrade

- [LOR-301] - The upgrade process is now compatible with hosted mender
- [LOR-285] - Add upgrade condition to the release file
- [LOR-290] - Check if there is enough free space before migrating
- [LOR-291] - Delete old user /etc after commit (or new after rollback)
- [LOR-293] - Update condition check

### Changed

Upgrade

- [LOR-303] - Use signed update artifacts

System

- [LOR-302] - Update manager to v0.6

### Fixed

- [LOR-275] - Version ID not computed correctly in /etc/os-release
- [LOR-298] - Manager debug log output on serial login
- [LOR-322] - WPF channel config default setup not done
- [LOR-323] - traceroute6 returns "sendto: Invalid argument"
- [LOR-326] - ping and traceroute need root privileges to run
- [LOR-329] - opkg overlay_root is wrong regarding the overlay
- [LOR-330] - current version of chrony doesn't support cmd onoffline needed by nm-dispatcher script
- [LOR-331] - nm-disptacher script return always 1
- [LOR-334] - chrony daemon displayed as crashed from rc-status but is ok

## [0.5.0-rc.2] - 2019-02-13

### Fixed

- Manager GUI v0.5.1

## [0.5.0-rc.1] - 2019-02-13

### Added

- [LOR-277] Enable hardware crypto acceleration support (used by OpenSSL and OpenSSH)
- [LOR-265] Add 2dBi antenna gain support for AU/US regions
- [LOR-71] Basic Station support
- [LOR-212] Add WPF autoquit_threshold
- [LOR-256] Add 2dBi antenna files for AU/US

### Changed

- Outdoor / indor antenna profiles are now 2dBi / 4dBi profiles
- ChirpStack Gateway Bridge updated to version 3.7.0
- Use hardware profiles related forwarder configuration files
- Manager v0.5.0
- pmonitor v0.4.2
- pmcli v0.4.0
- pvisor v0.2.0

## [0.4.0-rc.2] - 2019-12-24

### Changed

- [LOR-257] - Manager v0.4.2

### Fixed

- [LOR-256] - When changed through the manage GUI, the connection profile gets autoconnect=false
- [LOR-251] - Fix reference local.conf

## [0.4.0-rc.1] - 2019-12-22

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

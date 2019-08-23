# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- libpam
- Dynamic motd generation (using modified libpam)
- prerm/postinst OPKG state logic scripts for OpenRC init scripts
- Support for volatiles directories/symlinks/files on boot
- cron daemon OpenRC support
- NetworkManager DNS caching with dnsmasq
- Integration of manager-gui v0.0.1-beta.1
### Changed
- Default user changed from root without password to admin/lorix4u

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
- Updated motd with LOROS logo and with release information (build date, workspace hash)

## [0.0.1-beta.1] - 2019-07-10
### Added
- nmtui configuration util to configure more easily the NetworkManager with CLI
- LOROS unified manager including web interface (still needs work like certificate generation)<br/>
Including OpenRC boot script with supervisor management (respawn auto)
- Optimized wimg release image size (almost divided by 2)
- Created default NetworkManager connection configuration (DHCP by default with 192.168.8.8 static fallback)
- LOROS workspace build datetime into os-release file

### Changed
- Removed 1s u-boot boot time delay

### Fixed
- UBI missing PEBs for bad PEB handling

## [0.0.1-beta] - 2019-07-03
### Added
- LOROS release information in file `<loros>/release.conf`
- OPKG packages manager follows this release information

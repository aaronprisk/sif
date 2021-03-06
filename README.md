![sif logo](https://github.com/aaronprisk/sif/blob/main/sif-logo.png)



**S**imple **I**ntegrated **F**ailover

**SIF** is a simple HA tool for dual host KVM clusters. It's intended to be a turnkey, hands free tool for keeping your virtual machines highly available and limiting downtime in the case of a host failure.

## System Requirements
SIF should run on most modern Linux distributions, but there are a few important requirements:
* KVM with libvirt
* systemd
* openssh server on both hosts
* Configured shared storage (EX: NFS or iSCSI)

Please check the [wiki](https://github.com/aaronprisk/sif/wiki) for best practices and FAQs.

Distros tested: RHEL 8.4, Debian 10, Debian 11

## Installation
To install SIF, download files via a web browser or use git clone.

Browse to sif directory, then simply run:
```
chmod +x install.sh && ./install.sh
```
The SIF installer will start and guide you through the installation process.

## Important Notes

Please note that SIF is in active development and should be used accordingly.

![sif logo](https://github.com/aaronprisk/sif/blob/main/sif.png)



**S**imple **I**ntegrated **F**ailover

**SIF** is a simple tool for dual host KVM clusters. It's intended to be a turnkey, hands free tool for keeping your virtual machines highly available and limiting downtime in the case of a host failure.

## System Requirements
SIF should run on most modern Linux distributions, but there are a few important requirements:
* KVM with libvirt
* systemd
* openssh server on both hosts
* Configured shared storage (NFS or iscsi)

## Installation
To install SIF, download or use git clone to download files.

Then simply run:
```
chmod +x install.sh && ./install.sh
```
The SIF installer will start and guide you through the installation process.

## Important Notes

Please note that SIF is in active development and should be used accordingly.

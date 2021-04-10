#!/bin/bash
# SIF Migrate Script
# Initiated during planned migration of all VMs

# Ping check of Pair Host

# VM Live Migration
echo Migrating all VMs to $PAIRHOST
#for VMS in `virsh list --name`; do echo Migrating VM $VMS live && virsh migrate --live --persistent --undefinesource $VMS qemu+ssh://$HOST1/system; done
#for VMS in `virsh list --all --name`; do echo Migrating VM $VMS offline && virsh migrate --offline --persistent --undefinesource $VMS qemu+ssh://$HOST1/system; done

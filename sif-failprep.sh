#!/bin/bash
# SIF Self Prep
# Aaron J. Prisk 2021
# Script to prep host for safe failover by shutting down VMs and releasing resources

clear

for VMS in 'virsh list --name';
do
    echo Shutting down VM: $VMS && virsh shutdown VMS --mode acpi
done

#--------------------------------------------------------
#VMs will force shutdown after defined time in sif.conf
#--------------------------------------------------------

echo VM timeout of $VM_TIMEOUT has passed. Still active VMs will force power down.
sleep $VM_TIMEOUT

echo "Sleepy time is over.. time to missle kick the VMs into a coma."

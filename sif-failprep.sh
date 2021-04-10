#!/bin/bash
# SIF Self Prep
# Script to prep host for safe failover by shutting down VMs and releasing resources

for VMS in 'virsh list --name';
do
    echo "FAILOVER: Shutting down VM: $VMS" && virsh shutdown VMS --mode acpi
done

#--------------------------------------------------------
#VMs will force shutdown after defined time in sif.conf
#--------------------------------------------------------

echo VM timeout of $VM_TIMEOUT has passed. Still active VMs will force power down.
sleep $VM_TIMEOUT

for VMS in 'virsh list --name';
do
    echo "FAILOVER: Shutting down VM: $VMS" && virsh destroy VMS --graceful
done

#-----------------------------------------------------------
# Terminate watcher and wait for SystemD to restart service
#-----------------------------------------------------------
exit 0

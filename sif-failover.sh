#!/bin/bash
# SIF Failover Script
# Aaron J. Prisk 2021
# For unplanned host failure or cluster degradation

# Pre Failover Checks and Timers
# Give possibly frozen or misbehaving server time to release VM resources
# Default is VM_TIMEOUT in sif.conf multiplied by a factor of 2
echo "Sleeping for 2 VM Timeout Cycles to give host time to gracefully shut down VMs"
sleep $VM_TIMEOUT
sleep $VM_TIMEOUT

# DEFINE HOST PAIR VMS
cd host1xml
for f in *
do
    echo "Defining VM - $f"
done

# START VMS
for f in *
do
    echo "Starting VM - $f"
done

# Create Failover Flag
touch /mnt/vm/sif/failflag
echo $PAIRHOST > /mnt/vm/sif/failflag

# Create Failover Log
faillog=/mnt/vm/sif/log/failover-$(date +"%Y-%m-%d")
touch $faillog
echo "CRITICAL: Host failover triggered. Host at $PAIRHOST down at $(date)" >> $faillog
echo "The following VMs were migrated to active host:" >> $faillog

for f in *
do
    echo "$f " >> $faillog
done



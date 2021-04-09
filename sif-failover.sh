#!/bin/bash
# SIF Failover Script
# Aaron J. Prisk 2021
# For unplanned host failure or cluster degradation

# IMPORT SIF CONF
source sif.conf

# PRIMARY AND SECONDARY PING CHECK
echo "WARNING. HOST PAIR NOT RESPONDING"
echo "Trying secondary option..."
echo "HOST PAIR DOWN. Starting Fail-Over VM process."

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



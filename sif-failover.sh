#!/bin/bash
# SIF Failover Script
# For unplanned host failure or cluster degradation

# Pre Failover Checks and Timers
# Give possibly frozen or misbehaving server time to release VM resources
# Default is VM_TIMEOUT in sif.conf multiplied by a factor of 2
echo "Sleeping for 2 VM Timeout Cycles to give host time to gracefully shut down VMs"
sleep $VM_TIMEOUT
sleep $VM_TIMEOUT

# Create Host Pair VMs from XML
cd $SHAREDIR/sifxml/$PAIRID
for f in *
do
    echo "Defining VM - $f" && virsh create $f
done

# Start VMs
for f in *
do
    echo "Starting VM - $f" && virsh start $f
done

# Create Failover Flag
touch $SHAREDIR/siflog/failflag
echo $PAIRID > $SHAREDIR/siflog/failflag

# Create Failover Log
faillog=$SHAREDIR/siflog/failover-$(date +"%Y-%m-%d")
touch $faillog
printf "\nFAILOVER: Host failover triggered. Host at $PAIRHOST down at $(date)" >> $faillog
printf "\nFAILOVER: The following VMs were migrated to active host:" >> $faillog

for f in *
do
    echo -n "$f " >> $faillog
done

# Move to Restoration Phase
while [ -f $SHAREDIR/siflog/failflag ]
do
	echo "FAILOVER: Fail Flag still present. Pausing until next check."
        sleep $PING_INTERVAL
done

# Initiate Live Migration and SIF Cluster restoration
echo "FAILOVER: Fail Flag no longer present. Starting cluster restoration."
echo Migrating all transient VMs to $PAIRHOST
for VMS in `virsh list --transient --name`; do echo Migrating VM $VMS live && virsh migrate --live --persistent --undefinesource --unsafe $VMS qemu+ssh://$PAIRHOST/system; done
#--------------------------------------------------------------------------------
# Currently using --unsafe option as vms that didn't shutdown gracefully will fail to migrate without it. Adjustments will be needed later.
# Add additional error checking logic here to ensure restoration was successful.
#--------------------------------------------------------------------------------

# Update Failover Log
printf "\nRESTORATION: Restoration Complete at $(date)" >> $faillog

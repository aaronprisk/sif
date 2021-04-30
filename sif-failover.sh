#!/bin/bash
# SIF Failover Script
# For unplanned host failure or cluster degradation

# Pre Failover Checks and Timers
# Give possibly frozen or misbehaving server time to release VM resources
# Default is VM_TIMEOUT in sif.conf multiplied by number of VMs
cd $SHAREDIR/sifxml/$PAIRID
count=0
for v in *
do
    count=$((count + 1))
done
echo "Sleeping for $count VM Time cycles " && sleep $((VM_TIMEOUT * count))

# Create Host Pair VMs from XML
for f in *
do
    echo "Creating VM domain and starting - $f" && virsh create $f
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
echo "FAILOVER: Migrating all transient VMs to $PAIRHOST"
for VMS in `virsh list --transient --name`; do echo Migrating VM $VMS live && virsh migrate --live --persistent --undefinesource $VMS qemu+ssh://$PAIRHOST/system; done
#--------------------------------------------------------------------------------
# --unsafe option can be added to force move VMs with cache mode not set to NONE
#--------------------------------------------------------------------------------

# Update Failover Log
printf "\nRESTORATION: Restoration Complete at $(date)" >> $faillog

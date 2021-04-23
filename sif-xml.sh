#!/bin/bash
# SIF Nightly XML Export

# Import SIF Config
source /opt/sif/sif.conf

# Export persistent VM XML to sharedir as defined in sif.conf
for x in $(virsh list --persistent --name);
do
    virsh dumpxml $x > $sharedir/sifxml/$hostid/$x 
done

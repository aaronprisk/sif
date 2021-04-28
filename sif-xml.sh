#!/bin/bash
# SIF Nightly XML Export

# Import SIF Config
source /opt/sif/sif.conf

# Clear previous VM XML exports
rm $SHAREDIR/sifxml/$HOSTID/$x/*

# Export persistent VM XML to sharedir as defined in sif.conf
for x in $(virsh list --persistent --name);
do
    virsh dumpxml $x > $SHAREDIR/sifxml/$HOSTID/$x
done

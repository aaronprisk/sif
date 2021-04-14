#!/bin/bash
# SIF Migrate Script
# Initiated during planned migration of all VMs

echo "***********************************************************"
echo "***************** SIF PLANNED MIGRATION *******************"
echo "***********************************************************"
echo
echo "This SIF tool will migrate all VMs from this host to pair host." 
echo "1) TRANSIENT - Temporary transfer of RUNNING VMs to pair host."
echo "2) PERSISTENT - Longer term transfer of ALL VMS to pair host."
echo "3) EXIT"

while true; do
    read -p "What type of migration do you want to perform?(1 or 2): " migtype
    case $migtype in
        [1]* ) break;;
        [2]* ) break;;
        [3]* ) exit 0; break;;
        * ) echo "Please select available option.";;
    esac
done

# Host Pair Ping Check
ping -c1 localhost > /dev/null
if [ $? -eq 0 ]
  then
    echo "SUCCESS: This host has active networking."
  else
    echo "FAILURE: Error starting networking on localhost. Please check connectivity and try migration again."
    exit 0;
fi
ping -c1 $PAIRHOST > /dev/null
if [ $? -eq 0 ]
  then
    echo "SUCCESS: Host pair is active."
  else
      echo "FAILURE: Host pair is not responding. Please check connectivity and try migration again."
      exit 0;
fi
echo "-------------------------------------------"  
# VM Migration
if [ migtype == 1 ]
    then
        echo "*Starting transient migration of all VMs to $PAIRHOST"
        for VMS in `virsh list --name`; do echo Migrating VM $VMS live && virsh migrate --live $VMS qemu+ssh://$PAIRHOST/system; done
     else
        echo "*Starting persistent migration of all VMs to $PAIRHOST"
        echo "*Attempting live migration for powered on VMs"
        for VMS in `virsh list --name`; do echo Migrating VM $VMS live && virsh migrate --live --persistent --undefinesource $VMS qemu+ssh://$PAIRHOST/system; done
        echo "*Attempting offline migration for powered off VMs."
        for VMS in `virsh list --all --name`; do echo Migrating VM $VMS offline && virsh migrate --offline --persistent --undefinesource $VMS qemu+ssh://$PAIRHOST/system; done
fi
echo "SIF Migration has completed."
echo "If any VMs failed to migrate, please resolve error and run migration again."

#!/bin/bash
# SIF Setup Script
# Aaron J. Prisk
# Import Variables from SIF config
source sif.conf

echo "Welcome to SIF! The  Simple Integrated Failover tool for KVM."
echo "-------------------------------------------------------------"
echo "Here's what you'll need:"
echo "- 2 KVM hosts with properly configured shared storage (NFS or iscsi)"
echo "- You'll also need libvirt, systemd and ntp. That's it!"
echo "-------------------------------------------------------------"
read -r -p "Ready to get started? [Y/n] " input

case $input in
    [yY][eE][sS]|[yY])
                echo "Starting up..."
                ;;
    [nN][oO]|[nN])
                echo "Exiting..."
                exit 1
                ;;
    *)
        echo "Invalid input..."
        exit 1
        ;;
esac

echo ""
echo "Starting local ping test..."

ping -c1 localhost > /dev/null
if [ $? -eq 0 ]
  then
    echo "SUCCESS: This host has active networking."
  else
    echo "FAILURE: Error starting networking on localhost"
    echo "Ensure networking is enabled on this host and try SIF Setup again."
    exit 0;
fi

echo Starting host pair ping test - HOST IP: $PAIRHOST
ping -c1 $PAIRHOST > /dev/null
if [ $? -eq 0 ]
  then
    echo "SUCCESS: Host pair is active."
  else
    echo "FAILURE: Host pair is NOT Active."
    echo "Ensure Pair Host is active and reachable and try SIF Setup again."
    exit 0;
fi

echo "--------------------------------------"
echo "All test passed successfully!"
echo "SIF is ready to be installed."
echo "Proceed? (Y/N)"

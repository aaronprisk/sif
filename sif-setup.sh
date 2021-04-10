#!/bin/bash
# SIF Setup Script
# Aaron J. Prisk
# Import Variables from SIF config
source sif.conf

echo "Welcome to SIF! The  Simple Integrated Failover tool for KVM."
echo "---------------------------------------------------------------------"
echo "- Version 0.1"
echo "- https://github.com/aaronprisk/sif"
echo "---------------------------------------------------------------------"
read -r -p "Ready to get started? [Y/n] " input

case $input in
    [yY][eE][sS]|[yY])
                echo "Starting Setup..."
                ;;
    [nN][oO]|[nN])
                echo "Exiting..."
                exit 1
                ;;
    *)
        echo "Invalid input... (Y/N)"
        exit 1
        ;;
esac

# SIF preflight-checks here.
# Connect to other host.
# Assign hostids and pairids.

echo "--------------------------------------"
echo "All test passed successfully!"
echo "SIF is ready to be installed."
echo "Proceed? (Y/N)"
# Dump XML of each host into respected buckets
# Enable SystemD Service and Start SIF on both sides

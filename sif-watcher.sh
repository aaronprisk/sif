#!/bin/bash
# Aaron J Prisk 2021
# SIF Watcher
# Service that monitors connecitivty and uptime of paired SIF hosts

#Import SIF config
source sif.conf

echo "Checking Local Network Stack"

ping -c1 localhost > /dev/null
if [ $? -eq 0 ]
  then
    echo "SUCCESS: This host has active networking."
  else
    echo "FAILURE: Error starting networking on localhost"
    exit 0;
fi

ping -c1 $PAIRHOST > /dev/null
if [ $? -eq 0 ]
  then
    echo "SUCCESS: Host pair is active."
    echo "SUCCESS: Watcher Service will check back in $PING_INTERVAL seconds."
    exit 0
  else
    echo "WARNING: Host pair is NOT Active."
fi

# If this section is reached, the first ping attempt failed. Second attempt - Attempting secondary FAILHOST IP.

ping -c1 $FAILHOST > /dev/null
if [ $? -eq 0 ]
  then
    echo "SUCCESS: Failsafe interface is active."
    echo "SUCCESS: Watcher Service will check back in $PING_INTERVAL seconds."
    exit 0
  else
    echo "WARNING: Failsafe interface is NOT Active."
fi

# If this section is reached, the second attempt failed - Attempting Gateway Test IP

ping -c1 $FAILGW > /dev/null
if [ $? -eq 0 ]
  then
    echo "SUCCESS: Gateway is active."
  else
    echo "WARNING: Gateway is NOT Active."
fi

# ------------------------------------------------------------------------------------
# Perform Final Check. If this check fails, the system will begin failover procedures.
# Host waits for PING_INTERVAL before performing final test.
# ------------------------------------------------------------------------------------

echo "WARNING: Starting second check after configured ping interval - $PING_INTERVAL seconds"
sleep $PING_INTERVAL

ping -c1 localhost > /dev/null
if [ $? -eq 0 ]
  then
    echo "SUCCESS: This host has active networking."
  else
    echo "FAILURE: Error starting networking on localhost"
    echo "Ensure networking is enabled on this host and try SIF Setup again."
    exit 0;
fi

# Second Host Pair Check

ping -c1 $PAIRHOST > /dev/null
if [ $? -eq 0 ]
  then
    echo "SUCCESS: Host pair is active."
    echo "SUCCESS: Watcher Service will check back in $PING_INTERVAL seconds."
    exit 0
  else
    echo "WARNING: Host pair is NOT Active."
fi

# Second Fail Host Check.

ping -c1 $FAILHOST > /dev/null
if [ $? -eq 0 ]
  then
    echo "SUCCESS: Failsafe interface is active."
    echo "SUCCESS: Watcher Service will check back in $PING_INTERVAL seconds."
    exit 0
  else
    echo "WARNING: Failsafe interface is NOT Active."
fi

# Second Gateway Check.

ping -c1 $FAILGW > /dev/null
if [ $? -eq 0 ]
  then
    echo "SUCCESS: Gateway is active."
  else
    echo "WARNING: Gateway is NOT Active."
    echo "FAILOVER: THIS HOST IS DEGRADED"
    echo "FAILOVER: FAILOVER PROCEDURE WILL NOW START."
    source sif-failprep.sh
    exit 0
fi

#-------------------------------------------------------------"
# FAILOVER PREP AND INITIATION
#-------------------------------------------------------------

echo "---------------------------------------------------------"
echo "FAILOVER: PAIRED HOST $PAIRHOST IS DOWN."
echo "FAILOVER: FAILOVER PROCEDURE WILL NOW START."
echo "---------------------------------------------------------"
source sif-failover.sh
exit 0

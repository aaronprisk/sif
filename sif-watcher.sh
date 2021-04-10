#!/bin/bash
# SIF Watcher
# Service that monitors connecitivty and uptime of paired SIF hosts

# Start Watcher Loop
while true
do
	echo "Checking Local Network Stack"

	ping -c1 localhost > /dev/null
	if [ $? -eq 0 ]
	  then
	    echo "SUCCESS: This host has active networking."
	  else
	    echo "FAILURE: Error starting networking on localhost"
	    exit 0;
	fi

        # Start ping checks of defined addresses

	ping -c1 $PAIRHOST > /dev/null
	if [ $? -eq 0 ]
	  then
	    echo "SUCCESS: Host pair is active."
	    echo "SUCCESS: Watcher Service will check back in $PING_INTERVAL seconds."
            sleep $PING_INTERVAL
	  else
	    echo "WARNING: Host pair is NOT Active. Trying Fail Safe check."
	    ping -c1 $FAILHOST > /dev/null
	    if [ $? -eq 0 ]
	      then
	        echo "SUCCESS: Failsafe interface is active."
	        echo "SUCCESS: Watcher Service will check back in $PING_INTERVAL seconds."
                sleep $PING_INTERVAL
	      else
	        echo "WARNING: Failsafe interface is NOT Active."
		ping -c1 $FAILGW > /dev/null
		if [ $? -eq 0 ]
		  then
		    echo "SUCCESS: Gateway is active."
		  else
		    echo "WARNING: Gateway is NOT Active."
		fi
	    fi
	fi

	# ------------------------------------------------------------------------------------
	# If this checks fail, system will perform checks again.
	# Host waits for PING_INTERVAL before performing test.
	# ------------------------------------------------------------------------------------

	echo "WARNING: Starting second check after configured ping interval - $PING_INTERVAL seconds"
	sleep $PING_INTERVAL

	ping -c1 $PAIRHOST > /dev/null
	if [ $? -eq 0 ]
	  then
	    echo "SUCCESS: Host pair is active."
	    echo "SUCCESS: Watcher Service will check back in $PING_INTERVAL seconds."
            sleep $PING_INTERVAL
	  else
	    echo "WARNING: Host pair is NOT Active. Trying Fail Safe check."
	    ping -c1 $FAILHOST > /dev/null
	    if [ $? -eq 0 ]
	      then
	        echo "SUCCESS: Failsafe interface is active."
	        echo "SUCCESS: Watcher Service will check back in $PING_INTERVAL seconds."
                sleep $PING_INTERVAL
	      else
	        echo "WARNING: Failsafe interface is NOT Active."
		ping -c1 $FAILGW > /dev/null
		if [ $? -eq 0 ]
		  then
		    echo "SUCCESS: Gateway is active."
                    # Assume pair host is degraded. Start Failover procedure.
                    source /opt/sif/sif-failover.sh
		  else
                    # Assume host is degraded. Start fail prep procedure.
		    echo "WARNING: Gateway is NOT Active."
                    source /opt/sif/sif-failprep.sh

		fi
	    fi
	fi

done

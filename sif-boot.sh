#!/bin/bash
# SIF Boot
# Part of SIF stack that runs at boot time.

# Import SIF Config
source sif.conf

# Check for failflag in shared directory.
failfile=$SHAREDIR/siflog/failflag
if test -f "$failfile"; then
    echo "FAIL FLAG PRESENT"
    if grep -q $HOSTID < $SHAREDIR/siflog/failflag; then
        echo "FLAG IS FOR THIS HOST"
        echo "CLEARING FLAG" && rm $SHAREDIR/siflog/failflag
    fi
else
    echo "Fail Flag not present. Proceeding with normal boot."
fi

# Start SIF Watcher
source sif-watcher.sh

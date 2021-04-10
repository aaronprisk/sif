#!/bin/bash

if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

echo "****************************************************"
echo "**************** SIF INSTALLER * *******************"
echo "****************************************************"
echo
echo "This script installs the SIF Service on your computer."
read -s -n 1 -p "PRESS ANY KEY TO CONTINUE"
if [ -f /lib/systemd/system/sif.service ]; then
	echo -e "\n* SIF Service already installed. Exiting."
	exit
fi

echo "*Creating SIF Directory"
mkdir /opt/sif
echo "*Copying SIF Scripts"
cp -r * /opt/sif/ > /dev/null
echo "*Copying service file"
cp sif.service /lib/systemd/system/
echo "*Registering service"
systemctl daemon-reload
systemctl enable sif
echo "------------------------------------------------------------"
echo "*SIF Service is now installed."
echo "*Please run SIF Setup to complete installation:" 
echo "sudo /opt/sif/sif-setup.sh"

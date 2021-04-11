#!/bin/bash
# SIF Installation Script
if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

echo "****************************************************"
echo "***************** SIF INSTALLER ********************"
echo "****************************************************"
echo
if [ -f /lib/systemd/system/sif.service ]; then
	echo -e "\n* SIF Service already installed. Exiting."
	exit
fi

echo "Please ensure your system meets all requirements listed in README file before installing!"
echo "STEP 1) SIF Service Install"
while true; do
    read -p "Are you ready to install SIF? (y/n)" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) echo "Exiting installer..."; exit;;
        * ) echo "Please answer y or n.";;
    esac
done

echo "STEP 2) CHOOSE SIF HOST ID"
echo "SIF used a unique 1 or 0 identifier for each host in the cluster." 
echo "Each host MUST have a unique ID or SIF will not function correctly."
while true; do
    read -p "Which ID should this host use? (0 or 1?): " hostid
    case $hostid in
        [0]* ) echo "This host will use a HOSTID of 0. Ensure the other host uses 1."; break;;
        [1]* ) echo "This host will use a HOSTID of 1. Ensure the other host uses 0."; break;;
        * ) echo "Please answer 0 or 1.";;
    esac
done

echo "*Creating SIF Directory"
mkdir /opt/sif
echo "*Copying SIF Scripts"
cp $0/* /opt/sif/ > /dev/null
echo "*Copying service file"
cp $0/sif.service /lib/systemd/system/
echo "*Registering service"

echo "STEP 3) SHARED STORAGE CONFIGURATION"
echo "SIF requires a shared KVM storage directory for operation."
echo "Please enter path to shared directory omiting trailing /"
echo "Example - /mnt/share: "
read sharedir

echo "SIF will now attempt to write to specified shared directory..."
touch $sharedir/siftest
if [ ! -w "$file" ] ; then
    echo "Cannot write to Shared Directory. Please correct permissions and rerun SIF Setup."
    exit 1
fi

echo "*Creating SIF Directories in Shared Storage..."
mkdir $sharedir/sifxml
mkdir $sharedir/sifxml/$hostid
mkdir $sharedir/siflog
if [ ! -w "$sharedir/sifxml" ] ; then
    echo "Cannot create directories. Please correct permissions and rerun SIF Setup."
    exit 1
fi
echo "Operation Successful."
rm $sharedir/siftest

while true; do
    echo "STEP 3) KVM PAIR SETUP"
    echo "SIF is designed for two KVM hosts. Please enter the IP address of your pair host: "
    read pairip
    echo "STEP 4) FAILSAFE SETUP"
    echo "SIF uses backup IP addresses to ensure uptime. Best practice is set your failsafe IP as a VM running on the pair host."
    echo "Please enter a failsafe IP address: "
    read failip
    echo "SIF will also try to contact an avaiable gateway during failover to ensure network connectivity."
    echo "This could be your local gateway or a public one."
    echo "Please enter a gateway IP address: "
    read failgw
    echo "You entered:
    echo "------------------------------"
    echo "PAIR HOST: $pairip"    
    echo "FAIL HOST: $failip" 
    echo "FAIL GATEWAY: $failgw"
    echo "------------------------------""
    read -p "Are these values correct? (y/n)" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) echo "Please enter the correct values."; exit;;
        * ) echo "Please answer y or n.";;
    esac
done

# -------------------------------------
# INPUT USER VALUES INTO SIF CONF FILE
# -------------------------------------
sudo sed -i "s/EXAMPLEDIR/$pairip/g" /opt/sif/sif.conf
sudo sed -i "s/EXAMPLEFAIL/$failip/g" /opt/sif/sif.conf
sudo sed -i "s/EXAMPLEGW/$failgwip/g" /opt/sif/sif.conf

echo "STEP 4) SSH KEY SETUP"
echo "For automatic VM migrations to work, SIF uses SSH and key authentication."
echo "Please follow the prompts to setup SSH Key authentication."
ssh-keygen -t rsa
ssh-copy-id root@$pairip

echo "*Starting SIF service"
systemctl daemon-reload
systemctl enable sif
systemctl start sif
echo "------------------------------------------------------------"
echo "*SIF Service is now installed and running!"
echo "*Please complete SIF setup on other host, if not already done." 
exit 0
#!/bin/bash
# SIF Installation Script
if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

# -----------------------
# Pull working directory
# -----------------------
wd=$(dirname `dirname "$0"`)

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

echo
echo "STEP 2) CHOOSE SIF HOST ID"
echo "SIF used a unique 1 or 0 identifier for each host in the cluster." 
echo "Each host MUST have a unique ID or SIF will not function correctly."
while true; do
    read -p "Which ID should this host use? (0 or 1?): " hostid
    case $hostid in
        [0]* ) pairid=1; echo "This host will use a HOSTID of 0. Ensure the other host uses 1."; break;;
        [1]* ) pairid=0; echo "This host will use a HOSTID of 1. Ensure the other host uses 0."; break;;
        * ) echo "Please answer 0 or 1.";;
    esac
done

echo "*Creating SIF Directory"
mkdir /opt/sif
echo "*Copying SIF Scripts"
cp $wd/* /opt/sif/ > /dev/null
echo "*Setting execute bit for SIF scripts"
chmod +x /opt/sif/sif*
echo "*Copying service file"
cp $wd/sif.service /lib/systemd/system/
echo "*Registering service"

echo
echo "STEP 3) SHARED STORAGE CONFIGURATION"
echo "SIF requires a shared KVM storage directory for operation."
echo "Please enter path to shared directory ommiting trailing /"
echo "EX: /mnt/share"
read -p "Please enter shared directory: " sharedir

echo "*SIF will now attempt to write to specified shared directory..."
touch $sharedir/siftest
if [ ! -w "$sharedir/siftest" ] ; then
    echo "*Cannot write to Shared Directory. Please correct permissions and rerun SIF Setup."
    exit 1
fi

echo "*Creating SIF Directories in Shared Storage..."
mkdir $sharedir/sifxml
mkdir $sharedir/sifxml/$hostid
mkdir $sharedir/siflog
if [ ! -w "$sharedir/sifxml" ] ; then
    echo "*Cannot create directories. Please correct permissions and rerun SIF Setup."
    exit 1
fi
echo "*Operation Successful."
rm $sharedir/siftest

while true; do
    echo
    echo "STEP 4) KVM PAIR SETUP"
    echo "SIF is designed for two KVM hosts."
    read -p "Please enter the IP address of your pair host: " pairip
    echo
    echo "SIF uses backup IP addresses to ensure availibility."
    echo "Best practice is set your failsafe IP as a VM running on the pair host."
    read -p "Please enter a failsafe IP address: " failip
    echo
    echo "SIF will also try to contact an avaiable gateway during failover to ensure network connectivity."
    echo "This could be your local gateway or a public one."
    read -p "Please enter a gateway IP address: " failgw
    echo
    echo "You entered:"
    echo "------------------------------"
    echo "PAIR HOST: $pairip"
    echo "FAIL HOST: $failip"
    echo "FAIL GATEWAY: $failgw"
    echo "------------------------------"
    read -p "Are these values correct? (y/n)" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) echo "Please enter the correct values.";;
        * ) echo "Please answer y or n.";;
    esac
done

# -------------------------------------
# INPUT USER VALUES INTO SIF CONF FILE
# -------------------------------------
sudo sed -i "s/EXAMPLEHOSTID/$hostid/g" /opt/sif/sif.conf
sudo sed -i "s/EXAMPLEPAIRID/$pairid/g" /opt/sif/sif.conf
sudo sed -i "s+EXAMPLEDIR+$sharedir+g" /opt/sif/sif.conf
sudo sed -i "s/EXAMPLEIP/$pairip/g" /opt/sif/sif.conf
sudo sed -i "s/EXAMPLEFAIL/$failip/g" /opt/sif/sif.conf
sudo sed -i "s/EXAMPLEGW/$failgw/g" /opt/sif/sif.conf

echo
echo "STEP 5) SSH KEY SETUP"
echo "For automatic VM migrations to work, SIF uses SSH and key authentication."
echo "Please follow the prompts to setup SSH Key authentication."
ssh-keygen -t rsa
ssh-copy-id root@$pairip

echo "STEP 6) FIREWALL SETUP"
echo "*Creating Firewall Exceptions for live migration"
if [ -f /etc/redhat-release ]; then
  firewall-cmd --add-port=49152-49216/tcp --zone=public --permanent
  firewall-cmd --reload
fi
if [ -f /etc/lsb-release ]; then
   iptables -I INPUT -p tcp -m tcp --dport 49152:49216 -j ACCEPT
fi

echo "STEP 7) VM METADATA EXPORT"
echo "*Exporting existing VM metadata"
for x in $(virsh list --name);
do
    echo "Exporting - $x" && virsh dumpxml $x > $sharedir/sifxml/$hostid/$x 
done
echo "*Exporting Complete"

echo
echo "*Starting SIF service"
systemctl daemon-reload
systemctl enable sif
systemctl start sif
echo "------------------------------------------------------------"
echo "*SIF Service is now installed and running!"
echo "*Please complete SIF setup on other host, if not already done." 
exit 0

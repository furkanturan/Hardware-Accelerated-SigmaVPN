#!/bin/sh

clear

echo "Configuring Private Interface"

ifconfig eth1 192.168.2.50
sleep 3
ifconfig eth1 mtu 1600

echo "Configuring Public Interface"

ifconfig eth0 10.3.0.9
sleep 3
ifconfig eth0 promisc

echo "Installing SigmaVPN."

mkdir /usr/local
cp -r /mnt/sigmavpn/sigmavpn_installdir/* /usr/local/

echo "Running SigmaVPN."
echo ""

/usr/local/bin/sigmavpn -c /mnt/sigmavpn/demo1.conf

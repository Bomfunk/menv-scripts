#!/bin/bash

if [ ! -f inet_if ]
then
	echo "Network settings for these nodes were not found."
	echo "Aborting the networking script!"
	exit 1
fi

INET_IF=$(cat inet_if)

sudo ip link set f51-nh-adm down
sudo brctl delbr f51-nh-adm

sudo iptables -t nat -D POSTROUTING -o $INET_IF -s 172.16.0.0/255.255.255.0 -j MASQUERADE
sudo ip link set f51-nh-pub down
sudo brctl delbr f51-nh-pub

sudo ip link set f51-nh-prv down
sudo brctl delbr f51-nh-prv

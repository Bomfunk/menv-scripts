#!/bin/bash

if [ ! -f inet_if ]
then
	echo "Network settings for these nodes were not found."
	echo "Aborting the networking script!"
	exit 1
fi

INET_IF=$(cat inet_if)

sudo brctl addbr f51-nh-adm
sudo ip addr add 10.20.0.1/24 dev f51-nh-adm
sudo ip link set f51-nh-adm up

sudo brctl addbr f51-nh-pub
sudo ip addr add 172.16.0.1/24 dev f51-nh-pub
sudo ip link set f51-nh-pub up
sudo iptables -t nat -A POSTROUTING -o $INET_IF -s 172.16.0.0/255.255.255.0 -j MASQUERADE

sudo brctl addbr f51-nh-prv
sudo ip addr add 172.16.1.1/24 dev f51-nh-prv
sudo ip link set f51-nh-prv up
sudo ip link set f51-nh-prv promisc on

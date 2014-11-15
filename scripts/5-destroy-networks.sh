#!/bin/bash

if [ ! -f inet_if ]
then
	echo "Network settings for these nodes were not found."
	echo "Aborting the networking script!"
	exit 1
fi

INET_IF=$(cat inet_if)
source env.cfg

sudo ip link set $net_prefix-adm down
sudo brctl delbr $net_prefix-adm

sudo iptables -t nat -D POSTROUTING -o $INET_IF -s $pub_subnet.0/255.255.255.0 -j MASQUERADE
sudo ip link set $net_prefix-pub down
sudo brctl delbr $net_prefix-pub

sudo ip link set $net_prefix-prv down
sudo brctl delbr $net_prefix-prv

if $external_forward
then
	for i in $(seq 1 $forward_count)
	do
		sudo iptables -t nat -A PREROUTING -i $INET_IF -p tcp --dport ${ex_forw[$i]} -j DNAT --to ${ex_forw_to[$i]}
	done
fi

#!/bin/bash

if [ ! -f inet_if ]
then
	echo "Network settings for these nodes were not found."
	echo "Aborting the networking script!"
	exit 1
fi

INET_IF=$(cat inet_if)
source env.cfg

sudo brctl addbr $net_prefix-adm
sudo ip addr add $adm_subnet.1/24 dev $net_prefix-adm
sudo ip link set $net_prefix-adm up

sudo brctl addbr $net_prefix-pub
sudo ip addr add $pub_subnet.1/24 dev $net_prefix-pub
sudo ip link set $net_prefix-pub up
sudo iptables -t nat -A POSTROUTING -o $INET_IF -s $pub_subnet.0/255.255.255.0 -j MASQUERADE

sudo brctl addbr $net_prefix-prv
sudo ip addr add $prv_subnet.1/24 dev $net_prefix-prv
sudo ip link set $net_prefix-prv up
sudo ip link set $net_prefix-prv promisc on

if $external_forward
then
	for i in $(seq 1 $forward_count)
	do
		sudo iptables -t nat -A PREROUTING -i $INET_IF -p tcp --dport ${ex_forw[$i]} -j DNAT --to ${ex_forw_to[$i]}
	done
fi

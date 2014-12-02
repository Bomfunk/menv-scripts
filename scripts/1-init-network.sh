#!/bin/bash

if [ ! -f inet_if ]
then
	echo "Network settings for these nodes were not found."
	echo "Aborting the networking script!"
	exit 1
fi

INET_IF=$(cat inet_if)
source env.cfg

for i in $(seq 1 $networks)
do
	sudo brctl addbr $net_prefix-$i
	sudo ip addr add ${subnet[$i]}.1/24 dev $net_prefix-$i
	sudo ip link set $net_prefix-$i up

	if ${subnet_internet[$i]} ; then
		sudo iptables -t nat -A POSTROUTING -o $INET_IF -s ${subnet[$i]}.0/255.255.255.0 -j MASQUERADE
	fi
	if ${subnet_promisc[$i]} ; then
		sudo ip link set $net_prefix-$i promisc on
	fi
done

if $external_forward
then
	for i in $(seq 1 $forward_count)
	do
		sudo iptables -t nat -A PREROUTING -i $INET_IF -p tcp --dport ${ex_forw[$i]} -j DNAT --to ${ex_forw_to[$i]}
	done
fi

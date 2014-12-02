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
	if ${subnet_internet[$i]} ; then
		sudo iptables -t nat -D POSTROUTING -o $INET_IF -s ${subnet[$i]}.0/255.255.255.0 -j MASQUERADE
	fi
	sudo ip link set $net_prefix-$i down
	sudo brctl delbr $net_prefix-$i
done

if $external_forward
then
	for i in $(seq 1 $forward_count)
	do
		sudo iptables -t nat -D PREROUTING -i $INET_IF -p tcp --dport ${ex_forw[$i]} -j DNAT --to ${ex_forw_to[$i]}
	done
fi

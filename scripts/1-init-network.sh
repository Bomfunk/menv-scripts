#!/bin/bash

if [ ! -f $PATH_TO_ENV/statedir/inet_if ]
then
	echo "Network settings for these nodes were not found."
	echo "Aborting the networking script!"
	exit 1
fi

INET_IF=$(cat $PATH_TO_ENV/statedir/inet_if)
source $PATH_TO_ENV/env.cfg

for i in $(seq 1 $networks)
do
	if [ -z ${subnet_name[$i]} ]
	then
		net_name=$net_prefix-$i
	else
		net_name=$net_prefix-${subnet_name[$i]}
	fi

	sudo brctl addbr $net_name
	sudo ip addr add ${subnet[$i]}.1/24 dev $net_name
	sudo ip link set $net_name up

	if ${subnet_internet[$i]} ; then
		sudo iptables -t nat -A POSTROUTING -o $INET_IF -s ${subnet[$i]}.0/255.255.255.0 -j MASQUERADE
	fi
	if ${subnet_promisc[$i]} ; then
		sudo ip link set $net_name promisc on
	fi
done

if $external_forward
then
	for i in $(seq 1 $forward_count)
	do
		sudo iptables -t nat -A PREROUTING -p tcp --dport ${ex_forw[$i]} -j DNAT --to ${ex_forw_to[$i]}
	done
fi

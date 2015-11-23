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

	if ${subnet_internet[$i]} ; then
		sudo iptables -t nat -D POSTROUTING -o $INET_IF -s ${subnet[$i]}.0/255.255.255.0 -j MASQUERADE
	fi
	sudo ip link set $net_name down
	sudo brctl delbr $net_name
done

if $external_forward
then
	for i in $(seq 1 $forward_count)
	do
		sudo iptables -t nat -D PREROUTING -p tcp --dport ${ex_forw[$i]} -j DNAT --to ${ex_forw_to[$i]}
	done
fi

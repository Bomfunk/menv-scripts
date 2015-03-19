#!/bin/bash

ALL_ARGS=$(getopt -o y --long yes -n $0 -- "$@")
eval set -- "$ALL_ARGS"

NEEDCONFIRM=true
while true
do
	case "$1" in
		-y|--yes) NEEDCONFIRM=false ; shift ;;
		--) shift; break ;;
		*) echo "Internal error." ; exit 1 ;;
	esac
done

if [ $# -ne 2 ]
then
	echo "Usage: $0 [options] <PATH_TO_ENV> <INET_IF>"
	echo "Where PATH_TO_ENV is path to the environment - snapshots, configuration file etc.,"
	echo "and INET_IF is a network interface name which has access to Internet (for Public network)."
	echo "Options:"
	echo " -y/--yes		Proceed without asking for a confirmation."
	exit 1
fi

if [ $(cat /proc/sys/net/ipv4/ip_forward) == "0" ]
then
	echo "IP Forwarding is not enabled on this machine!"
	echo "It is necessary for the VMs to reach Internet."
	echo "Please enable it using this command and try again: \"echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward\""
	exit 1
fi

export PATH_TO_ENV=$(readlink -f $1)
if [ ! -d "$PATH_TO_ENV" ]
then
	echo "The specified environment directory doesn't exist, aborting."
	exit 1
fi

INET_IF=$2
INET_IF_IP4=$(ip -o -4 addr list $INET_IF | awk '{print $4}' | cut -d/ -f1)
source $PATH_TO_ENV/env.cfg

echo -n $INET_IF > $PATH_TO_ENV/inet_if

echo "What is going to be deployed is described below."
echo "------------------------------------------------"
echo "$deploy_desc"
if $NEEDCONFIRM
then
	echo "Do you want to continue? (yes/no)"
	
	read CONT_VAR
	
	if [ ! $CONT_VAR == "yes" ]
	then
		echo "Aborted."
		exit 1
	fi
fi

echo "Initializing network..."
./scripts/1-init-network.sh

echo "Applying saved snapshots..."
./scripts/2-apply-snapshots.sh

echo "Launching VMs..."
./scripts/3-launch-vms.sh

echo "All done. Use IP address $master_ip to access Fuel Master, and $horizon_ip for Horizon."
if $external_forward
then
	echo "Also, the following port forwards are set on this machine: "
	for i in $(seq 1 $forward_count)
	do
		echo ${INET_IF_IP4}:"${ex_forw[$i]} to ${ex_forw_to[$i]}"
	done
	echo
else
	echo "Port forwards were not configured on this machine."
fi
echo "Use destroy-env.sh script to tear down the environment and destroy the networks."
echo "Enjoy!"

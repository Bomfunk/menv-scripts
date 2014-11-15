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

if [ $# -ne 1 ]
then
	echo "Usage: $0 [options] <INET_IF>"
	echo "Where INET_IF is a network interface name which has access to Internet (for Public network)."
	echo "Options:"
	echo " -y/--yes		Proceed without asking for a confirmation."
	exit 1
fi

INET_IF=$1
source env.cfg

echo -n $INET_IF > inet_if

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

if [ -f not-clear ]
then
	echo "Applying saved snapshots..."
	./scripts/2-apply-snapshots.sh
fi

echo "Launching VMs..."
touch not-clear
./scripts/3-launch-vms.sh

echo "All done. Use IP address $master_ip to access Fuel Master, and $horizon_ip for Horizon."
echo "Use destroy-env.sh script to tear down the environment and destroy the networks."
echo "Enjoy!"

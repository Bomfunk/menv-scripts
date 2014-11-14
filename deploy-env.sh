#!/bin/bash

if [ $# -ne 1 ]
then
	echo "Usage: $0 <INET_IF>"
	echo "Where INET_IF is a network interface name which has access to Internet (for Public network)."
	exit 1
fi

INET_IF=$1

echo -n $INET_IF > inet_if

echo "What is going to be deployed is described below."
echo "------------------------------------------------"
echo "Network bridges:"
echo "1. f51-nh-adm, 10.20.0.1/24"
echo "2. f51-nh-pub, 172.16.0.1/24, with Internet access"
echo "3. f51-nh-prv, 172.16.1.1/24, with promiscuous mode"
echo "Virtual machines:"
echo "1. fuel-pm, 1 CPU, 1 GB RAM"
echo "2. slave node used as controller, 1 CPU, 1 GB RAM"
echo "3. slave node used as ceph-osd, 1 CPU, 2 GB RAM"
echo "4. slave node used as compute, 1 CPU, 3 GB RAM"
echo
echo "Do you want to continue? (yes/no)"

read CONT_VAR

if [ ! $CONT_VAR == "yes" ]
then
	echo "Aborted."
	exit 1
fi

echo "Initializing network..."
./scripts/1-init-network.sh

if [ -f not-clear ]
then
	echo "Applying saved snapshots..."
	./scripts/2-apply-snapshots.sh
fi

echo "Launching VMs..."
./scripts/3-launch-vms.sh 3
touch not-clear

echo "All done. Use IP address 10.20.0.2 to access Fuel Master, and 172.16.0.2 for Horizon."
echo "Use destroy-env.sh script to tear down the environment and destroy the networks."
echo "Enjoy!"

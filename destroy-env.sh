#!/bin/bash

if [ ! -f inet_if ]
then
	echo "There isn't any environment yet, is there?.."
	echo "(The inet_if file was not found, it should contain the name of network interface with Internet access.)"
	exit 1
fi

INET_IF=$(cat inet_if)

echo "Destroying VMs..."
./scripts/4-destroy-vms.sh 3

echo "Destroying remaining networks..."
./scripts/5-destroy-networks.sh

echo "Clearing diff qcow2's..."
./scripts/2-apply-snapshots.sh

rm -f not-clear inet_if

echo "All done. Goodbye!"

#!/bin/bash

if [ $# -ne 1 ]
then
	echo "Usage: $0 <PATH_TO_ENV>"
	echo "Where PATH_TO_ENV is path to the environment - snapshots, configuration file etc."
	exit 1
fi

export PATH_TO_ENV=$(readlink -e $1)
if [ ! -d "$PATH_TO_ENV" ]
then
	echo "The specified environment directory doesn't exist, aborting."
	exit 1
fi

if [ ! -f $PATH_TO_ENV/inet_if ]
then
	echo "There isn't any environment yet, is there?.."
	echo "(The inet_if file was not found, it should contain the name of network interface with Internet access.)"
	exit 1
fi

INET_IF=$(cat $PATH_TO_ENV/inet_if)
source $PATH_TO_ENV/env.cfg

pushd $(dirname $0) > /dev/null
echo "Initializing network..."
./scripts/1-init-network.sh

echo "Launching VMs..."
./scripts/3-launch-vms.sh

echo "Resuming the environment has been completed."

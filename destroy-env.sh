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
if [ ! -e "$PATH_TO_ENV/env.cfg" ]
then
	echo "There is no env.cfg file in the directory, so it does not appear to be a valid environment directory."
	echo "Please make sure you have specified correct directory."
	exit 1
fi

if [ ! -f $PATH_TO_ENV/statedir/inet_if ]
then
	echo "There isn't any environment yet, is there?.."
	echo "(The statedir/inet_if file was not found, it should contain the name of network interface with Internet access.)"
	exit 1
fi

INET_IF=$(cat $PATH_TO_ENV/statedir/inet_if)
source $PATH_TO_ENV/env.cfg

pushd $(dirname $0) > /dev/null
echo "Destroying VMs..."
./scripts/4-destroy-vms.sh

echo "Destroying remaining networks..."
./scripts/5-destroy-networks.sh

echo "Removing diff qcow2's..."
sudo rm $PATH_TO_ENV/statedir/diff*
sudo rm $PATH_TO_ENV/statedir/*.log

rm -f $PATH_TO_ENV/statedir/inet_if

rmdir $PATH_TO_ENV/statedir 2> /dev/null

echo "All done. Goodbye!"

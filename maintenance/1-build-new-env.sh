#!/bin/bash

if [ $# -ne 2 ]
then
	echo "Usage: $0 <PATH_TO_ENV> <INET_IF>"
	echo "Where PATH_TO_ENV is path to the environment - snapshots, configuration file etc.,"
	echo "and INET_IF is a network interface name which has access to Internet (for Public network)."
	exit 1
fi

export PATH_TO_ENV=$(readlink -e $1)
if [ ! -d "$PATH_TO_ENV" ]
then
	echo "The specified environment directory doesn't exist, aborting."
	exit 1
fi

INET_IF=$2
source $PATH_TO_ENV/env.cfg

mkdir -p $PATH_TO_ENV/statedir
echo -n $INET_IF > $PATH_TO_ENV/statedir/inet_if

pushd $(dirname $0)/.. > /dev/null
./scripts/1-init-network.sh
./maintenance/new-disks.sh
./maintenance/fuel-pm.sh

ssh-keygen -P "" -f $PATH_TO_ENV/master-key

if [ -z $master_name ]
then
	mname="master"
else
	mname=$master_name
fi

echo "When master node finishes OS installing, it usually goes down instead of rebooting - that's how QEMU works by default."
echo "Simply execute \"sudo virsh start $vm_prefix-$mname\" to bring it back up. To monitor it's initial state, use \"watch -n 15 sudo virsh list --all\""
echo "Once master node is ready, launch the next script: maintenance/2-launch-slaves.sh"

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
	echo "Usage: $0 [options] <PATH_TO_ENV>"
	echo "Where PATH_TO_ENV is path to the environment - snapshots, configuration file etc.,"
	echo "Options:"
	echo " -y/--yes		Proceed without asking for a confirmation."
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

if $NEEDCONFIRM
then
	echo "WARNING: If you did not stop the VMs properly, they will be terminated immediately (without ACPI signal)."
	echo "Are you sure you want to proceed with suspension? (yes/no)"
	
	read CONT_VAR
	
	if [ ! $CONT_VAR == "yes" ]
	then
		echo "Aborted."
		exit 1
	fi
fi

echo "Stopping/undefining VMs..."
./scripts/4-destroy-vms.sh

echo "Destroying networks..."
./scripts/5-destroy-networks.sh

echo "All done. To resume the environment, please run './resume-env.sh <PATH_TO_ENV>'."

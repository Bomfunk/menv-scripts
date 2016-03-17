#!/bin/bash

ALL_ARGS=$(getopt -o y --long yes -o i --long info -n $0 -- "$@")
eval set -- "$ALL_ARGS"

function info {
    export PATH_TO_ENV=$(readlink -e $2)
    if [ ! -d "$PATH_TO_ENV" ]
    then
        echo "The specified environment directory doesn't exist, aborting."
        exit 1
    fi
    echo "Use IP address $master_ip to access Fuel Master, and $horizon_ip for Horizon."
    if $external_forward
    then
        echo "Also, the following port forwards are set on this machine: "
        echo "(Note: the IP of this host on $INET_IF is $INET_IF_IP)"
        for i in $(seq 1 $forward_count)
        do  
            echo -n "0.0.0.0:${ex_forw[$i]} to ${ex_forw_to[$i]}"
            if [ $i -lt $forward_count ] ; then echo "," ; else echo "." ; fi
        done
        echo
    else
        echo "Port forwards were not configured on this machine."
    fi

    echo -n "If you use sshuttle, here is the suggested command for it: sshuttle -r mirantis@$INET_IF_IP "
    for i in $(seq 1 $networks)
    do
        echo -n "${subnet[i]}.0/24 "
    done
    echo ; echo
}

NEEDCONFIRM=true
while true
do
	case "$1" in
		-y|--yes) NEEDCONFIRM=false ; shift ;;
        -i|--info) info ; exit 1;;
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
    echo " -i/--info    Get the information about network settings"
	exit 1
fi

if [ $(cat /proc/sys/net/ipv4/ip_forward) == "0" ]
then
	echo "WARNING: IP Forwarding is not enabled on this machine!"
	echo "It is necessary for the VMs to reach Internet."
	echo "To enable it, you can use the following command and try again: \"echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward\""

	echo "Do you want to continue? (yes/no)"
	read CONT_VAR
	if [ ! $CONT_VAR == "yes" ]
	then
		echo "Aborted."
		exit 1
	fi
fi

export PATH_TO_ENV=$(readlink -e $1)
if [ ! -d "$PATH_TO_ENV" ]
then
	echo "The specified environment directory doesn't exist, aborting."
	exit 1
fi

INET_IF=$2
INET_IF_IP=$(ip -o -4 addr list $INET_IF | awk '{print $4}' | cut -d/ -f1)
source $PATH_TO_ENV/env.cfg

if [ ! -e /sys/class/net/$INET_IF ]
then
	echo "WARNING: The specified interface ($INET_IF) does not exist (/sys/class/net/$INET_IF was not found)."

	echo "Do you want to continue? (yes/no)"
	read CONT_VAR
	if [ ! $CONT_VAR == "yes" ]
	then
		echo "Aborted."
		exit 1
	fi
fi

pidof libvirtd > /dev/null 2> /dev/null

if [ $? -ne 0 ]
then
	echo "WARNING: The 'libvirtd' process does not seem to be running."

	echo "Do you want to continue? (yes/no)"
	read CONT_VAR
	if [ ! $CONT_VAR == "yes" ]
	then
		echo "Aborted."
		exit 1
	fi
fi

mkdir -p $PATH_TO_ENV/statedir
echo -n $INET_IF > $PATH_TO_ENV/statedir/inet_if

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

pushd $(dirname $0) > /dev/null
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
	echo "(Note: the IP of this host on $INET_IF is $INET_IF_IP)"
	for i in $(seq 1 $forward_count)
	do
		echo -n "0.0.0.0:${ex_forw[$i]} to ${ex_forw_to[$i]}"
		if [ $i -lt $forward_count ] ; then echo "," ; else echo "." ; fi
	done
	echo
else
	echo "Port forwards were not configured on this machine."
fi

echo -n "If you use sshuttle, here is the suggested command for it: sshuttle -r mirantis@$INET_IF_IP "
for i in $(seq 1 $networks)
do
	echo -n "${subnet[i]}.0/24 "
done
echo ; echo # Double line break

echo "Use destroy-env.sh script to tear down the environment and destroy the networks."
echo "Enjoy!"

#!/bin/bash

function show_bridges_info {
bridges_desc="Network bridges:\n"
for i in $(seq 1 $networks)
do
        if [ -z ${subnet_name[$i]} ]
        then
                net_name=$net_prefix-$i
        else
                net_name=$net_prefix-${subnet_name[$i]}
        fi
	bridges_desc="$bridges_desc $net_name, ${subnet[i]}.1/24, Internet_access=${subnet_internet[i]}, promiscuous_mode=${subnet_promisc[i]}\n"
done
printf "$bridges_desc\n"
}

function show_vms_info {
vms_desc="Virtual machines:
 fuel-pm, $master_vcpus CPU, $master_ram MB RAM
"
for i in $(seq 1 $slaves_count)
do
        if [ -z ${slave_name[$i]} ]
        then
                VM_NAME=$vm_prefix-slave-$i
        else
                VM_NAME=$vm_prefix-${slave_name[$i]}
        fi
	vms_desc="$vms_desc $VM_NAME, ${slave_vcpus[i]} CPU, ${slave_ram[i]} MB\n"
done
printf "$vms_desc\n"
}

function show_net_info {
        echo "Use IP address $master_ip to access Fuel Master, and $horizon_ip for Horizon."
        echo  
        if $external_forward
        then
                echo "Also, the following port forwards are configured for all interfaces(0.0.0.0) on this host: "
                echo "(Note: the IP of this host on $INET_IF is $INET_IF_IP)"
                for i in $(seq 1 $forward_count)
                do
                        printf "%-20s to %-20s %-s\n" "$INET_IF_IP:${ex_forw[$i]}" "${ex_forw_to[$i]}" "${ex_forw_desc[$i]}"
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


function print_usage {
	echo "Usage: $0 [options] <PATH_TO_ENV> <INET_IF>"
	echo "Where PATH_TO_ENV is path to the environment - snapshots, configuration file etc.,"
	echo "and INET_IF is a network interface name which has access to Internet (for Public network)."
	echo "Options:"
	echo " -y/--yes		Proceed without asking for a confirmation."
	echo " -i/--info	Get the information about network settings (if this parameter is specified, <INET_IF> is no longer required.)"
	echo "--nostart	Create VMs but do not start them (shut them down immediately after starting)"
}

ALL_ARGS=$(getopt -o yi --long yes,info -n $0 -- "$@")
eval set -- "$ALL_ARGS"

NEEDCONFIRM=true
NEEDINFO=false
while true
do
	case "$1" in
		-y|--yes) NEEDCONFIRM=false; shift ;;
		-i|--info) NEEDINFO=true; shift ;;
		--nostart) NOSTART=$1; shift ;;
		--) shift; break ;;
		*) echo "Internal error." ; exit 1 ;;
	esac
done

if [ $# -lt 1 ] || [ $# -gt 2 ]
then
	print_usage
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
source $PATH_TO_ENV/env.cfg

if [ $# -eq 2 ]
then
	INET_IF=$2
else
	if $NEEDINFO
	then
		if [ ! -f $PATH_TO_ENV/statedir/inet_if ]
		then
			echo "There isn't any environment yet, is there?.."
			echo "(The statedir/inet_if file was not found, it should contain the name of network interface with Internet access.)"
			exit 1
		fi
		
		INET_IF=$(cat $PATH_TO_ENV/statedir/inet_if)
	else
		print_usage
		exit 1
	fi
fi
INET_IF_IP=$(ip -o -4 addr list $INET_IF | awk '{print $4}' | cut -d/ -f1)

if $NEEDINFO
then
	show_bridges_info
	show_vms_info
	show_net_info
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
show_bridges_info
show_vms_info
show_net_info


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
./scripts/3-launch-vms.sh $START

echo "All done."
show_net_info

echo "Use destroy-env.sh script to tear down the environment and destroy the networks."
echo "Enjoy!"

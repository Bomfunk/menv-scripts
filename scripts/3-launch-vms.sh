#!/bin/bash

source $PATH_TO_ENV/env.cfg

VM_NAME=$vm_prefix-pm
virt_net_params=""
for i in $(seq 1 $networks)
do
	virt_net_params="$virt_net_params --bridge=$net_prefix-$i,mac=${subnet_mac_prefix[$i]}:00"
done

if [ -z $master_ram ]
then
	if [ -z $default_ram ]
	then
		master_ram=1024
	else
		master_ram=$default_ram
	fi
fi

if [ -z $master_vcpus ]
then
	if [ -z $default_vcpus ]
	then
		master_vcpus=1
	else
		master_vcpus=$default_vcpus
	fi
fi

sudo virt-install -n $VM_NAME \
 -r $master_ram \
 --vcpus=$master_vcpus \
 --arch=x86_64 \
 --disk path=$PATH_TO_ENV/diff.fuel-pm.qcow2,bus=virtio,device=disk,format=qcow2 \
 $virt_net_params \
 --boot hd \
 --noautoconsole \
 --graphics vnc,listen=0.0.0.0 
if [ $? -ne 0 ]
then
	echo "Error encountered while launching a VM: terminating."
	echo "Note: you may want to launch destroy-env.sh script to clear the networks/incomplete vms."
	exit 1
fi

echo -n $VM_NAME
sudo virsh vncdisplay $VM_NAME

echo "Waiting for fuel master to become ready..."
$PATH_TO_ENV/preparation/wait-for-master.sh
echo "Master node is ready! Waiting 30 seconds before proceeding..."
sleep 30

for i in $(seq 1 $slaves_count)
do
	VM_NAME=$vm_prefix-slave-$i
	if [ $i -lt 10 ]
	then
		MACNUM="0$i"
	else
		MACNUM=$i
	fi
	
	virt_net_params=""
	for j in $(seq 1 $networks)
	do
		virt_net_params="$virt_net_params --bridge=$net_prefix-$j,mac=${subnet_mac_prefix[$j]}:$MACNUM"
	done

	if [ -z ${node_disks[$i]} ]
	then
		if [ -z $default_disks ]
		then
			node_disks[$i]=1
		else
			node_disks[$i]=$default_disks
		fi
	fi
	
	virt_disks_params=""
	for j in $(seq 1 ${node_disks[$i]})
	do
		virt_disks_params="$virt_disks_params --disk path=$PATH_TO_ENV/diff.fuel-slave-$i-$j.qcow2,bus=virtio,device=disk,format=qcow2"
	done

	if [ -z ${slave_ram[$i]} ]
	then
		if [ -z $default_ram ]
		then
			slave_ram[$i]=1024
		else
			slave_ram[$i]=$default_ram
		fi
	fi

	if [ -z ${slave_vcpus[$i]} ]
	then
		if [ -z $default_vcpus ]
		then
			slave_vcpus[$i]=1
		else
			slave_vcpus[$i]=$default_vcpus
		fi
	fi

	sudo virt-install -n $VM_NAME \
	 -r ${slave_ram[$i]} \
	 --vcpus=${slave_vcpus[$i]} \
	 --arch=x86_64 \
	 $virt_disks_params \
	 $virt_net_params \
	 --boot network,hd \
	 --noautoconsole \
	 --graphics vnc,listen=0.0.0.0
	if [ $? -ne 0 ]
	then
		echo "Error encountered while launching a VM: terminating."
		echo "Note: you may want to launch destroy-env.sh script to clear the networks/incomplete vms."
		exit 1
	fi
	
	echo -n $VM_NAME
	sudo virsh vncdisplay $VM_NAME

	if [ ! -z $pause_between_slaves ] && [ $i -lt $slaves_count ]
	then
		echo "Sleeping for $pause_between_slaves..."
		sleep $pause_between_slaves
	fi
done

$PATH_TO_ENV/preparation/post-launch.sh

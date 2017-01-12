#!/bin/bash

source $PATH_TO_ENV/env.cfg

START=true
if [ "$1" == "--nostart" ]
then
	START=false
fi

if [ -z $master_name ]
then
	VM_NAME=$vm_prefix-master
else
	VM_NAME=$vm_prefix-$master_name
fi

virt_net_params=""
for i in $(seq 1 $networks)
do
	if [ -z ${subnet_name[$i]} ]
	then
		net_name=$net_prefix-$i
	else
		net_name=$net_prefix-${subnet_name[$i]}
	fi

	virt_net_params="$virt_net_params --bridge=$net_name,mac=${subnet_mac_prefix[$i]}:00,model=virtio"
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

sudo virsh desc $VM_NAME > /dev/null 2> /dev/null
if [ $? -eq 0 ] ; then sudo virsh destroy $VM_NAME ; sudo virsh undefine $VM_NAME ; fi
sudo virt-install -n $VM_NAME \
 -r $master_ram \
 --vcpus=$master_vcpus \
 --cpu host \
 --arch=x86_64 \
 --disk path=$PATH_TO_ENV/statedir/diff.fuel-pm.qcow2,bus=virtio,device=disk,format=qcow2 \
 $virt_net_params \
 --boot hd \
 --noautoconsole \
 --serial file,path=$PATH_TO_ENV/statedir/${VM_NAME}.log \
 --graphics vnc,listen=0.0.0.0 
if [ $? -ne 0 ]
then
	echo "Error encountered while launching a VM: terminating."
	echo "Note: you may want to launch destroy-env.sh script to clear the networks/incomplete vms."
	exit 1
fi

echo -n $VM_NAME
sudo virsh vncdisplay $VM_NAME

if [ $START = true ]
then
	echo "Waiting for fuel master to become ready..."
	$PATH_TO_ENV/preparation/wait-for-master.sh

	if [ -z $pause_before_slaves ] 
	then
		pause_before_slaves=30
	fi
else
	sudo virsh destroy $VM_NAME
fi

echo "Master node is ready!"
if [ $START = true ]
then
	echo "Waiting ${pause_before_slaves} seconds before proceeding..."
	sleep ${pause_before_slaves}
fi

for i in $(seq 1 $slaves_count)
do
	if [ -z ${slave_name[$i]} ]
	then
		VM_NAME=$vm_prefix-slave-$i
	else
		VM_NAME=$vm_prefix-${slave_name[$i]}
	fi

	if [ $i -lt 10 ]
	then
		MACNUM="0$i"
	else
		MACNUM=$i
	fi
	
	virt_net_params=""
	for j in $(seq 1 $networks)
	do
		if [ -z ${subnet_name[$j]} ]
		then
			net_name=$net_prefix-$j
		else
			net_name=$net_prefix-${subnet_name[$j]}
		fi

		virt_net_params="$virt_net_params --bridge=$net_name,mac=${subnet_mac_prefix[$j]}:$MACNUM,model=virtio"
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
		virt_disks_params="$virt_disks_params --disk path=$PATH_TO_ENV/statedir/diff.fuel-slave-$i-$j.qcow2,bus=virtio,device=disk,format=qcow2"
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

	sudo virsh desc $VM_NAME > /dev/null 2> /dev/null
	if [ $? -eq 0 ] ; then sudo virsh destroy $VM_NAME ; sudo virsh undefine $VM_NAME ; fi
	sudo virt-install -n $VM_NAME \
	 -r ${slave_ram[$i]} \
	 --vcpus=${slave_vcpus[$i]} \
         --cpu host \
	 --arch=x86_64 \
	 $virt_disks_params \
	 $virt_net_params \
	 --boot network,hd \
	 --noautoconsole \
         --serial file,path=$PATH_TO_ENV/statedir/${VM_NAME}.log \
	 --graphics vnc,listen=0.0.0.0
	if [ $? -ne 0 ]
	then
		echo "Error encountered while launching a VM: terminating."
		echo "Note: you may want to launch destroy-env.sh script to clear the networks/incomplete vms."
		exit 1
	fi
	
	echo -n $VM_NAME
	sudo virsh vncdisplay $VM_NAME

	if [ $START = true ]
	then
		if [ ! -z $pause_between_slaves ] && [ $i -lt $slaves_count ]
		then
			echo "Sleeping for $pause_between_slaves..."
			sleep $pause_between_slaves
		fi
	else
		sudo virsh destroy $VM_NAME
	fi
done

$PATH_TO_ENV/preparation/post-launch.sh

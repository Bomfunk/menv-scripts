#!/bin/bash

source $PATH_TO_ENV/env.cfg

VM_NAME=$vm_prefix-pm
virt_net_params=""
for i in $(seq 1 $networks)
do
	virt_net_params="$virt_net_params --bridge=$net_prefix-$i,mac=${subnet_mac_prefix[$i]}:00"
done
sudo virt-install -n $VM_NAME \
 -r $master_ram \
 --vcpus=1 \
 --arch=x86_64 \
 --disk path=$PATH_TO_ENV/diff.fuel-pm.qcow2,bus=virtio,device=disk,format=qcow2 \
 $virt_net_params \
 --boot hd \
 --noautoconsole \
 --graphics vnc,listen=0.0.0.0 
if [ $? -ne 0 ]
then
	echo "Error encountered while launching a VM: terminating."
	echo "Note: you may want to launch ./destroy-env.sh script to clear the networks/incomplete vms."
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
	
	virt_disks_params=""
	for j in $(seq 1 ${node_disks[$i]})
	do
		virt_disks_params="$virt_disks_params --disk path=$PATH_TO_ENV/diff.fuel-slave-$i-$j.qcow2,bus=virtio,device=disk,format=qcow2"
	done

	sudo virt-install -n $VM_NAME \
	 -r ${slave_ram[$i]} \
	 --vcpus=1 \
	 --arch=x86_64 \
	 $virt_disks_params \
	 $virt_net_params \
	 --boot network \
	 --noautoconsole \
	 --graphics vnc,listen=0.0.0.0
	if [ $? -ne 0 ]
	then
		echo "Error encountered while launching a VM: terminating."
		echo "Note: you may want to launch ./destroy-env.sh script to clear the networks/incomplete vms."
		exit 1
	fi
	
	echo -n $VM_NAME
	sudo virsh vncdisplay $VM_NAME
done

$PATH_TO_ENV/preparation/post-launch.sh

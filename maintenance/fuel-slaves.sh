#!/bin/bash

source env.cfg

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
	sudo virt-install -n $VM_NAME \
	 -r ${slave_ram[$i]} \
	 --vcpus=1 \
	 --arch=x86_64 \
	 --disk path=$(pwd)/fuel-slave-$i.qcow2,bus=virtio,device=disk,format=qcow2 \
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
	virsh vncdisplay $VM_NAME
done

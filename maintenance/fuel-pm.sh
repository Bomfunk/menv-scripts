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

sudo virt-install -n $VM_NAME \
 -r $master_ram \
 --vcpus=1 \
 --arch=x86_64 \
 --disk path=$PATH_TO_ENV/fuel-pm.qcow2,bus=virtio,device=disk,format=qcow2 \
 --cdrom $iso_path \
 $virt_net_params \
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

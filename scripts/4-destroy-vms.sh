#!/bin/bash

source $PATH_TO_ENV/env.cfg

if [ -z $master_name ]
then
	VM_NAME=$vm_prefix-master
else
	VM_NAME=$vm_prefix-$master_name
fi

sudo virsh destroy $VM_NAME
sudo virsh undefine $VM_NAME
for i in $(seq 1 $slaves_count)
do
	if [ -z ${slave_name[$i]} ]
	then
		VM_NAME=$vm_prefix-slave-$i
	else
		VM_NAME=$vm_prefix-${slave_name[$i]}
	fi

	sudo virsh destroy $VM_NAME
	sudo virsh undefine $VM_NAME
done

#!/bin/bash

source env.cfg

sudo virsh destroy $vm_prefix-pm
sudo virsh undefine $vm_prefix-pm
for i in $(seq 1 $slaves_count)
do
	sudo virsh destroy $vm_prefix-slave-$i
	sudo virsh undefine $vm_prefix-slave-$i
done

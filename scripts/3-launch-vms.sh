#!/bin/bash

source env.cfg

VM_NAME=$vm_prefix-pm
sudo virt-install -n $VM_NAME \
 -r 1024 \
 --vcpus=1 \
 --arch=x86_64 \
 --disk path=$(pwd)/diff.fuel-pm.qcow2,bus=virtio,device=disk,format=qcow2 \
 --network bridge=$net_prefix-adm,mac=$adm_mac_prefix:00 \
 --network bridge=$net_prefix-pub,mac=$pub_mac_prefix:00 \
 --network bridge=$net_prefix-prv,mac=$prv_mac_prefix:00 \
 --boot hd \
 --noautoconsole \
 --graphics vnc,listen=0.0.0.0 

echo -n $VM_NAME
sudo virsh vncdisplay $VM_NAME

echo "Waiting for fuel master to become ready..."
./preparation/wait-for-master.sh
echo "Master node is ready! Waiting 10 seconds before proceeding..."
sleep 10

for i in $(seq 1 $slaves_count)
do
	VM_NAME=$vm_prefix-slave-$i
	if [ $i -lt 10 ]
	then
		MACNUM="0$i"
	else
		MACNUM=$i
	fi
	
	sudo virt-install -n $VM_NAME \
	 -r ${slave_ram[$i]} \
	 --vcpus=1 \
	 --arch=x86_64 \
	 --disk path=$(pwd)/diff.fuel-slave-$i.qcow2,bus=virtio,device=disk,format=qcow2 \
	 --network bridge=$net_prefix-adm,mac=$adm_mac_prefix:$MACNUM \
	 --network bridge=$net_prefix-pub,mac=$pub_mac_prefix:$MACNUM \
	 --network bridge=$net_prefix-prv,mac=$prv_mac_prefix:$MACNUM \
	 --boot network \
	 --noautoconsole \
	 --graphics vnc,listen=0.0.0.0
	
	echo -n $VM_NAME
	sudo virsh vncdisplay $VM_NAME
done

./preparation/post-launch.sh

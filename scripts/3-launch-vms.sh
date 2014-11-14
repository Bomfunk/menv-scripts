#!/bin/bash

if [ $# -ne 1 ]
then
	echo "Usage: $0 <slaves_count>"
	exit 1
fi

slave_ram[1]=3072
slave_ram[2]=2048
slave_ram[3]=1024
slave_ram[4]=1024
slave_ram[5]=1024
slave_ram[6]=1024
slave_ram[7]=1024
slave_ram[8]=1024
slave_ram[9]=1024
slave_ram[10]=1024

VM_NAME=f51-nonha-pm
sudo virt-install -n $VM_NAME \
 -r 1024 \
 --vcpus=1 \
 --arch=x86_64 \
 --disk path=$(pwd)/fuel-pm.qcow2,bus=virtio,device=disk,format=qcow2 \
 --network bridge=f51-nh-adm,mac=52:54:00:DD:C8:00 \
 --network bridge=f51-nh-pub,mac=52:54:00:BE:22:00 \
 --network bridge=f51-nh-prv,mac=52:54:00:22:7A:00 \
 --boot hd \
 --noautoconsole \
 --graphics vnc,listen=0.0.0.0 

echo -n $VM_NAME
sudo virsh vncdisplay $VM_NAME

ssh-keygen -R 10.20.0.2
echo "Waiting for fuel master to become ready..."
echo "(Please type \"yes\" here if requested...)"

COBBLER_LISTEN=0
sleep 30
while [ $COBBLER_LISTEN -lt 3 ]
do
	COBBLER_LISTEN=$(ssh -i master-key root@10.20.0.2 dockerctl shell cobbler netstat -lntp | wc -l)
	sleep 15
done
echo "Master node is ready! Waiting 10 seconds before proceeding..."
sleep 10

for (( i=1; i<=$1; i++ ))
do
	VM_NAME=f51-nonha-slave-$i
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
	 --disk path=$(pwd)/fuel-slave-$i.qcow2,bus=virtio,device=disk,format=qcow2 \
	 --network bridge=f51-nh-adm,mac=52:54:00:DD:C8:$MACNUM \
	 --network bridge=f51-nh-pub,mac=52:54:00:BE:22:$MACNUM \
	 --network bridge=f51-nh-prv,mac=52:54:00:22:7A:$MACNUM \
	 --boot network \
	 --noautoconsole \
	 --graphics vnc,listen=0.0.0.0
	
	echo -n $VM_NAME
	sudo virsh vncdisplay $VM_NAME
done

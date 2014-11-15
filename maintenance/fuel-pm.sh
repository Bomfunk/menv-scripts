#!/bin/bash

source env.cfg

VM_NAME=$vm_prefix-pm

sudo virt-install -n $VM_NAME \
 -r 1024 \
 --vcpus=1 \
 --arch=x86_64 \
 --disk path=$(pwd)/fuel-pm.qcow2,bus=virtio,device=disk,format=qcow2 \
 --cdrom $iso_path \
 --network bridge=$net_prefix-adm,mac=$adm_mac_prefix:00 \
 --network bridge=$net_prefix-pub,mac=$pub_mac_prefix:00 \
 --network bridge=$net_prefix-prv,mac=$prv_mac_prefix:00 \
 --noautoconsole \
 --graphics vnc,listen=0.0.0.0 

echo -n $VM_NAME
virsh vncdisplay $VM_NAME

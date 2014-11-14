#!/bin/sh

VM_NAME=f51-nonha-pm

virt-install -n $VM_NAME \
 -r 1024 \
 --vcpus=1 \
 --arch=x86_64 \
 --disk path=$(pwd)/fuel-pm.qcow2,bus=virtio,device=disk,format=qcow2 \
 --cdrom /home/bomfunk/iso/MirantisOpenStack-5.1.iso \
 --network bridge=f51-nh-adm,mac=52:54:00:DD:C8:00 \
 --network bridge=f51-nh-pub,mac=52:54:00:BE:22:00 \
 --network bridge=f51-nh-prv,mac=52:54:00:22:7A:00 \
 --noautoconsole \
 --graphics vnc,listen=0.0.0.0 

echo -n $VM_NAME
virsh vncdisplay $VM_NAME

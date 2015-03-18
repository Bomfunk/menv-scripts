#!/bin/bash

source $PATH_TO_ENV/env.cfg

qemu-img create -f qcow2 $PATH_TO_ENV/fuel-pm.qcow2 65536M
for i in $(seq 1 $slaves_count)
do
	if [ -z ${node_disks[$i]} ]
	then
		if [ -z $default_disks ]
		then
			node_disks[$i]=1
		else
			node_disks[$i]=$default_disks
		fi
	fi
	for j in $(seq 1 ${node_disks[$i]})
	do
		qemu-img create -f qcow2 $PATH_TO_ENV/fuel-slave-$i-$j.qcow2 65536M
	done
done

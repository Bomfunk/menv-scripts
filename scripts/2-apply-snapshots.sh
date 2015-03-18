#!/bin/bash

source $PATH_TO_ENV/env.cfg

sudo rm -f $PATH_TO_ENV/diff.fuel-pm.qcow2
qemu-img create -f qcow2 -b $PATH_TO_ENV/snapshots/fuel-pm.qcow2 $PATH_TO_ENV/diff.fuel-pm.qcow2
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
		sudo rm -f $PATH_TO_ENV/diff.fuel-slave-$i-$j.qcow2
		if [ -f $PATH_TO_ENV/snapshots/fuel-slave-$i-$j.qcow2 ]
		then
			qemu-img create -f qcow2 -b $PATH_TO_ENV/snapshots/fuel-slave-$i-$j.qcow2 $PATH_TO_ENV/diff.fuel-slave-$i-$j.qcow2
		else
			qemu-img create -f qcow2 $PATH_TO_ENV/diff.fuel-slave-$i-$j.qcow2 65536M
		fi
	done
done

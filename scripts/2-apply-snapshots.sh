#!/bin/bash

source $PATH_TO_ENV/env.cfg

sudo rm -f $PATH_TO_ENV/diff.fuel-pm.qcow2
qemu-img create -f qcow2 -b $PATH_TO_ENV/snapshots/fuel-pm.qcow2 $PATH_TO_ENV/diff.fuel-pm.qcow2
for i in $(seq 1 $slaves_count)
do
	for j in $(seq 1 ${node_disks[i]})
	do
		sudo rm -f $PATH_TO_ENV/diff.fuel-slave-$i-$j.qcow2
		qemu-img create -f qcow2 -b $PATH_TO_ENV/snapshots/fuel-slave-$i-$j.qcow2 $PATH_TO_ENV/diff.fuel-slave-$i-$j.qcow2
	done
done

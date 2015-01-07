#!/bin/bash

source env.cfg

sudo rm -f diff.fuel-pm.qcow2
qemu-img create -f qcow2 -b snapshots/fuel-pm.qcow2 diff.fuel-pm.qcow2
for i in $(seq 1 $slaves_count)
do
	for j in $(seq 1 ${node_disks[i]})
	do
		sudo rm -f diff.fuel-slave-$i-$j.qcow2
		qemu-img create -f qcow2 -b snapshots/fuel-slave-$i-$j.qcow2 diff.fuel-slave-$i-$j.qcow2
	done
done

#!/bin/bash

source $PATH_TO_ENV/env.cfg

qemu-img create -f qcow2 $PATH_TO_ENV/fuel-pm.qcow2 65536M
for i in $(seq 1 $slaves_count)
do
	for j in $(seq 1 ${node_disks[$i]})
	do
		qemu-img create -f qcow2 $PATH_TO_ENV/fuel-slave-$i-$j.qcow2 65536M
	done
done

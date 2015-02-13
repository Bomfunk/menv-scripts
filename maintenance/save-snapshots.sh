#!/bin/bash

source $PATH_TO_ENV/env.cfg

mkdir $PATH_TO_ENV/snapshots
echo "Compressing fuel-pm:"
qemu-img convert -O qcow2 -c -p $PATH_TO_ENV/fuel-pm.qcow2 $PATH_TO_ENV/snapshots/fuel-pm.qcow2 && sudo rm $PATH_TO_ENV/fuel-pm.qcow2
for i in $(seq 1 $slaves_count)
do
	for j in $(seq 1 ${node_disks[$i]})
	do
		echo "Compressing fuel-slave-$i-$j:"
		qemu-img convert -O qcow2 -c -p $PATH_TO_ENV/fuel-slave-$i-$j.qcow2 $PATH_TO_ENV/snapshots/fuel-slave-$i-$j.qcow2 && sudo rm $PATH_TO_ENV/fuel-slave-$i-$j.qcow2
	done
done

./scripts/2-apply-snapshots.sh

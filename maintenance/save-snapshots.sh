#!/bin/bash

source env.cfg

mkdir snapshots
echo "Compressing fuel-pm:"
qemu-img convert -O qcow2 -c -p fuel-pm.qcow2 snapshots/fuel-pm.qcow2 && sudo rm fuel-pm.qcow2
for i in $(seq 1 $slaves_count)
do
	for j in $(seq 1 ${node_disks[$i]})
	do
		echo "Compressing fuel-slave-$i-$j:"
		qemu-img convert -O qcow2 -c -p fuel-slave-$i-$j.qcow2 snapshots/fuel-slave-$i-$j.qcow2 && sudo rm fuel-slave-$i-$j.qcow2
	done
done

./scripts/2-apply-snapshots.sh

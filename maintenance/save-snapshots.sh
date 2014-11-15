#!/bin/bash

source env.cfg

mkdir snapshots
echo "Compressing fuel-pm:"
qemu-img convert -O qcow2 -c -p fuel-pm.qcow2 snapshots/fuel-pm.qcow2 && sudo rm fuel-pm.qcow2
for i in $(seq 1 $slaves_count)
do
	echo "Compressing fuel-slave-$i:"
	qemu-img convert -O qcow2 -c -p fuel-slave-$i.qcow2 snapshots/fuel-slave-$i.qcow2 && sudo rm fuel-slave-$i.qcow2
done

./scripts/2-apply-snapshots.sh

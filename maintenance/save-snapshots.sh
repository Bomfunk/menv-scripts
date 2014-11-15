#!/bin/bash

source env.cfg

mkdir snapshots
qemu-img convert -O qcow2 -c fuel-pm.qcow2 snapshots/fuel-pm.qcow2 && rm fuel-pm.qcow2
for i in $(seq 1 $slaves_count)
do
	qemu-img convert -O qcow2 -c fuel-slave-$i.qcow2 snapshots/fuel-slave-$i.qcow2 && rm fuel-slave-$i.qcow2
done

./scripts/2-apply-snapshots.sh

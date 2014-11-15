#!/bin/bash

source env.cfg

sudo rm -f diff.fuel-pm.qcow2
qemu-img create -f qcow2 -b snapshots/fuel-pm.qcow2 diff.fuel-pm.qcow2
for i in $(seq 1 $slaves_count)
do
	sudo rm -f diff.fuel-slave-$i.qcow2
	qemu-img create -f qcow2 -b snapshots/fuel-slave-$i.qcow2 diff.fuel-slave-$i.qcow2
done

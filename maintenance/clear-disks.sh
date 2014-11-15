#!/bin/bash

source env.cfg

rm -f fuel-pm.qcow2
qemu-img create -f qcow2 fuel-pm.qcow2 65536M
for i in $(seq 1 $slaves_count)
do
	rm -f fuel-slave-$i.qcow2
	qemu-img create -f qcow2 fuel-slave-$i.qcow2 65536M
done

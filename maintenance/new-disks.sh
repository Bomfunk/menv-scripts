#!/bin/bash

source env.cfg

qemu-img create -f qcow2 fuel-pm.qcow2 65536M
for i in $(seq 1 $slaves_count)
do
	qemu-img create -f qcow2 fuel-slave-$i.qcow2 65536M
done

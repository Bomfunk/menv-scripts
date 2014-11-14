#!/bin/bash

if [ $# -ne 1 ]
then
	echo "Usage: $0 <slaves_count>"
	exit 1
fi

rm -f fuel-pm.qcow2
qemu-img create -f qcow2 fuel-pm.qcow2 65536M
for i in $(seq 1 $1)
do
	rm -f fuel-slave-$i.qcow2
	qemu-img create -f qcow2 fuel-slave-$i.qcow2 65536M
done

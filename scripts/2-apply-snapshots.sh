#!/bin/bash

for i in *.qcow2
do
	sudo rm $i
	qemu-img create -f qcow2 -b snapshots/$i $i
done

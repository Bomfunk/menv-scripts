#!/bin/bash

if [ $# -ne 1 ]
then
	echo "Usage: $0 <slaves_count>"
	exit 1
fi

sudo virsh destroy f51-nonha-pm
sudo virsh undefine f51-nonha-pm
for i in $(seq 1 $1)
do
	sudo virsh destroy f51-nonha-slave-$i
	sudo virsh undefine f51-nonha-slave-$i
done

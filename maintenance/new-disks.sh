#!/bin/bash

source $PATH_TO_ENV/env.cfg

if [ -z $master_disk_size ]
then
	if [ -z $default_disk_size ]
	then
		SIZE=100G
	else
		SIZE=$default_disk_size
	fi
else
	SIZE=$master_disk_size
fi

qemu-img create -f qcow2 $PATH_TO_ENV/fuel-pm.qcow2 $SIZE

for i in $(seq 1 $slaves_count)
do
	if [ -z ${node_disks[$i]} ]
	then
		if [ -z $default_disks ]
		then
			node_disks[$i]=1
		else
			node_disks[$i]=$default_disks
		fi
	fi

	for j in $(seq 1 ${node_disks[$i]})
	do
		ndsvar="node_${i}_disk_${j}_size"
		echo "DEBUG: ndsvar is $ndsvar"
		if [ -z ${!ndsvar} ]
		then
			echo "This var was not declared."
			if [ -z $default_disk_size ]
			then
				SIZE=100G
			else
				SIZE=$default_disk_size
			fi
		else
			SIZE=${!ndsvar}
			echo "This var is declared and is $SIZE."
		fi
		qemu-img create -f qcow2 $PATH_TO_ENV/fuel-slave-$i-$j.qcow2 $SIZE
	done
done

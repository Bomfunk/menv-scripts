#!/bin/bash

if [ $# -ne 1 ]
then
	echo "Usage: $0 <INET_IF>"
	echo "Where INET_IF is a network interface name which has access to Internet (for Public network)."
	exit 1
fi

INET_IF=$1
source env.cfg

echo -n $INET_IF > inet_if

./scripts/1-init-network.sh
./maintenance/new-disks.sh
./maintenance/fuel-pm.sh

ssh-keygen -P "" -f master-key

echo "When master node finishes OS installing, it usually goes down instead of rebooting - that's how QEMU works by default."
echo "Simply execute \"sudo virsh start $vm_prefix-pm\" to bring it back up. To monitor it's initial state, use \"watch -n 15 sudo virsh list --all\""
echo "Once master node is ready, launch the next script: ./maintenance/2-launch-slaves.sh"

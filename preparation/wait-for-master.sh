#!/bin/bash

source env.cfg

COBBLER_LISTEN=0
sleep 30
echo "I will be trying to contact the master node through SSH every 15 seconds to see if it started listening to at least 3 ports in cobbler container. Please standby..."
while [ $COBBLER_LISTEN -lt 3 ]
do
	COBBLER_LISTEN=$(ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i master-key root@${subnet[1]}.2 dockerctl shell cobbler netstat -lntp | wc -l 2> /dev/null)
	sleep 15
done

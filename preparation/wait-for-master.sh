#!/bin/bash

source env.cfg

COBBLER_LISTEN=0
sleep 30
while [ $COBBLER_LISTEN -lt 3 ]
do
	COBBLER_LISTEN=$(ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i master-key root@$adm_subnet.2 dockerctl shell cobbler netstat -lntp | wc -l)
	sleep 15
done

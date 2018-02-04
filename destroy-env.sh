#!/bin/bash

. select_env.sh		# Issue the prompt for the environments; PATH_TO_ENV is exported; error checks are performed in select_env.sh

echo "PATH_TO_ENV: $PATH_TO_ENV"

INET_IF=$(cat $PATH_TO_ENV/statedir/inet_if)
source $PATH_TO_ENV/env.cfg

pushd $(dirname $0) > /dev/null
echo "Destroying VMs..."
./scripts/4-destroy-vms.sh

echo "Destroying remaining networks..."
./scripts/5-destroy-networks.sh

echo "Removing diff qcow2's..."
sudo rm $PATH_TO_ENV/statedir/diff*
sudo rm $PATH_TO_ENV/statedir/*.log

rm -f $PATH_TO_ENV/statedir/inet_if

rmdir $PATH_TO_ENV/statedir 2> /dev/null

echo "All done. Goodbye!"

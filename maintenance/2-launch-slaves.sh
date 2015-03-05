#!/bin/bash

if [ $# -ne 1 ]
then
	echo "Usage: $0 <PATH_TO_ENV>"
	echo "Where PATH_TO_ENV is path to the environment - snapshots, configuration file etc.,"
	exit 1
fi

export PATH_TO_ENV=$(readlink -f $1)
if [ ! -d "$PATH_TO_ENV" ]
then
	echo "The specified environment directory doesn't exist, aborting."
	exit 1
fi

source $PATH_TO_ENV/env.cfg

./maintenance/fuel-slaves.sh

echo "Now configure and deploy the environment."
echo "Do not forget to add master-key.pub to .ssh/authorized_keys of the master node."
echo "If you are not using 5.1, then you might want to check the preparation/ folder - it may need editing."
echo "After everything is ready - stop it properly and execute the final script: ./3-stop-and-save.sh"

#!/bin/bash

if [ $# -ne 1 ]
then
	echo "Usage: $0 <PATH_TO_ENV>"
	echo "Where PATH_TO_ENV is path to the environment - snapshots, configuration file etc.,"
	exit 1
fi

./maintenance/save-snapshots.sh
./destroy-env.sh

echo "Congratulations! Your new mobile environment is ready to be used."

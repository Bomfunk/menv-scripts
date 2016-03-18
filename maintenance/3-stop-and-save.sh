#!/bin/bash

if [ $# -ne 1 ]
then
	echo "Usage: $0 <PATH_TO_ENV>"
	echo "Where PATH_TO_ENV is path to the environment - snapshots, configuration file etc.,"
	exit 1
fi

export PATH_TO_ENV=$(readlink -e $1)
if [ ! -d "$PATH_TO_ENV" ]
then
	echo "The specified environment directory doesn't exist, aborting."
	exit 1
fi
if [ ! -e "$PATH_TO_ENV/env.cfg" ]
then
	echo "There is no env.cfg file in the directory, so it does not appear to be a valid environment directory."
	echo "Please make sure you have specified correct directory."
	exit 1
fi

pushd $(dirname $0)/.. > /dev/null
./maintenance/save-snapshots.sh
./destroy-env.sh $PATH_TO_ENV

echo "Congratulations! Your new mobile environment is ready to be used."

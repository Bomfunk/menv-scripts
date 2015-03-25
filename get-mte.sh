#!/bin/bash

server="172.18.66.13"
envs="~/mte/"

if [ $# -ne 1 ]
then
	echo "Usage: $0 <env_to_get>"
	echo "If you want to get ALL available environments, just specify \"all\". That might take a while though."
	echo "Here are the environments that are available on the server:"
	rsync $server::mte/\*
	exit 1
fi

wenv=$1

if [ "$wenv" == "all" ]; then
    wenv=""
fi

rsync --delete-after -avzP $server::mte/$wenv $envs
if [ $? -ne 0 ]
then
	echo "rsync died unexpectedly. Requesting environments list in case you specified wrong one..."
	echo "Here are the environments that are available on the server:"
	rsync $server::mte/\*
	exit 1
fi
find ${envs} -type f -name '*-key*' -exec chmod 600 '{}' \;

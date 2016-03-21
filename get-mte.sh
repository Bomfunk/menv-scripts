#!/bin/bash

server="172.18.186.226"
envs_path="$HOME/mte/"
compare=false

ALL_ARGS=$(getopt -o cp:s: --long compare,path:,server: -n $0 -- "$@")
eval set -- "$ALL_ARGS"
while true
do
	case "$1" in
                -c|--compare) compare=true; shift 1; ;;
		-p|--path) envs_path=$2 ; shift 2 ;;
		-s|--server) server=$2 ; shift 2 ;;
		--) shift; break ;;
		*) echo "Internal error." ; exit 1 ;;
	esac
done

if [ $# -ne 1 ]
then
	echo "Usage: $0 [parameters] <env_to_get>"
	echo "If you want to get ALL available environments, just specify \"all\". That might take a while though."
	echo "Available parameters:"
	echo "	-c|--compare: Compare if local mte copy differs from copy on remote server, print changed on server files list and exit."
	echo "	-p|--path <directory> : Path to the directory that will store the environments locally. Default is ~/mte/ (\$HOME/mte/)."
	echo "	-s|--server <host_or_ip> : IP address of the rsync server with \"mte\" module. Default is 172.18.186.226".
	echo "Here are the environments that are available on the server:"
	rsync $server::mte/\*
	exit 1
fi

wenv=$1

if [ "$wenv" == "all" ]; then
    wenv=""
fi

if [ "$compare" = true ] ; then
   rsync -an  --out-format="[%t]:%o:%f:Last Modified %M" $server::mte/$wenv $envs_path/
   exit 1
fi

rsync --delete-after -avzP $server::mte/$wenv $envs_path
if [ $? -ne 0 ]
then
	echo "rsync died unexpectedly. Requesting environments list in case you specified wrong one..."
	echo "Here are the environments that are available on the server:"
	rsync $server::mte/\*
	exit 1
fi
find $envs_path -type f -name '*-key*' -exec chmod 600 '{}' \;

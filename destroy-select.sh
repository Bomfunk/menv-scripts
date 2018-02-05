#!/bin/bash
#
# Display selection prompt for the running environments.

declare -a envs=`ps -ef | grep "[s]tatedir" | sed -e 's/^.*-drive file=\([^,]\+\).*$/\1/g' | sed -e 's/stated.*$//g' | uniq`
if [ -z "$envs" ]; then
	echo "no environment running"
	exit 1
fi

PS3="Select environment: "
select path_to_env in ${envs[@]}
do
	if [ -n "$path_to_env" ]
	then
		break
	fi
done


./destroy-env.sh $path_to_env

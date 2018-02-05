#!/bin/bash
#
# Display selection prompt for the running environments.

select PATH_TO_ENV in `ps -ef | grep "[s]tatedir" | sed -e 's/^.*-drive file=\([^,]\+\).*$/\1/g' | sed -e 's/stated.*$//g' | uniq`
do
	test ! $PATH_TO_ENV || break
done

test ! $PATH_TO_ENV || { echo "no environment running"; exit 1; }

./destroy-env.sh $PATH_TO_ENV

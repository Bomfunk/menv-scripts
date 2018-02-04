#!/bin/bash 
#
# Display prompt for the environments to be destroyed.
#

# Populate processes[] with pid of the running machines
#
function set_proc() {
	 processes=( $( ps aux | grep --extended-regexp --word-regexp `virsh list --name 2> /dev/null | tr '\n' ' ' | sed 's/ \(\w\)/|\1/g'` | grep -v grep | awk '{print $2}' ) ) 
		 # domain[[|domain]...]
}

# Print out path to envrionment(s).
#
function dump_env() {
	set_proc; for pid in ${processes[@]}
	do
		cmdline=/proc/${pid}/cmdline	# cmdline file name
						# print out only env name; statedir and the following path are stripped
	        echo `cat $cmdline | tr '\000' ' ' | sed -n 's/.*-drive file=\([^,]\+\).*/\1/p' | sed 's/statedir.*//'`
	done
}


declare -a processes	# qemu processes array

# Prepare select loop.
PS3="Please choose the environment: "; select PATH_TO_ENV in ` dump_env | uniq ` # do not display repetative entries
do 
	if [ $PATH_TO_ENV ]
	 then
	   break
	 fi
done

# Error-check
if [ ! -d "$PATH_TO_ENV" ]
then
	echo "The specified environment directory doesn't exist, aborting."
	exit 1
elif [ ! -e "$PATH_TO_ENV/env.cfg" ]; then
	echo "There is no env.cfg file in the directory, so it does not appear to be a valid environment directory."
	echo "Please make sure you have specified correct directory."
	exit 1
elif [ ! -f $PATH_TO_ENV/statedir/inet_if ]; then
	echo "There isn't any environment yet, is there?.."
	echo "(The statedir/inet_if file was not found, it should contain the name of network interface with Internet access.)"
	exit 1
fi

export PATH_TO_ENV

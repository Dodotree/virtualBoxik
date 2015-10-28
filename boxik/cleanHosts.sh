#!/bin/bash

##Run this script only as root
if [ "$(id -u)" != "0" ]; then
  exec sudo "$0" "$@"
fi

source $(dirname $0)/boxikScripts/boxik_config

##Make sure no one else is editing either the ansible hosts or ssh hosts files.
LOCKDIR="/var/lock/boxikHostFileLock"
mkdir $LOCKDIR 2>/dev/null || {
			echo "Another program is editing the ssh hosts file.";
			exit 2;
		}

N=$'\n'
com='vboxmanage list runningvms | grep -oP "\"\K.*(?=\")"'
exist=""

##Get list of running VM's from ALL users
for users in $(cut -d: -f1 /etc/passwd);do
	output=$(su -l $users -c "$com" 2>/dev/null) 
	if ! [ -z "$output" ] && ! [[ $output =~ "not available" ]];then
		exist=$exist${output[@]}";"
	fi
done

##Get list of hosts from the ssh hosts file, and the ansiblehosts file, storing into 2 arrays.
hosts=( $(grep -oP 'Host \K.*?(?=HostName )'<<< $(ed -s $HOSTFILE <<< "/$START/+,/$END/- g/./" 2>/dev/null )) )
ansHosts=( $(cut -d$'\n' -f1 <<< $( ed -s $ANS_HOSTS <<< "/$ANS_START/+,/$ANS_END/- g/./" 2>/dev/null )) )

##Loop through SSH hosts
for host in ${hosts[@]};do
	if ! [[ $exist =~ $host ]];then

		##Get line number for ed
		lineNum="$(grep -onP "Host $host" $HOSTFILE | cut -d: -f1)"

		##WARNING: Each of the hosts are ASSUMED to be 4 lines total, from Host to IdentityFile.
		## If changed the below ed line will delete excessive/not-enough lines.
		
		ed -s $HOSTFILE <<< "$lineNum,$lineNum+3d${N}w"
		echo "Deleted powered off/non-existent host $host from $HOSTFILE"	

	fi
done

##Loop through Ansible hosts
for host in ${ansHosts[@]};do
	if ! [[ $exist =~ $host ]];then

		##Same as above, just ed deletes only 1 line.
		ansLine="$(grep -onP "$host" $ANS_HOSTS | cut -d: -f1)"
		ed -s $ANS_HOSTS <<< "${ansLine}d${N}w"
		echo "Deleted powered off/non-existent host $host from $ANS_HOSTS"

	fi
done

rm -r $LOCKDIR

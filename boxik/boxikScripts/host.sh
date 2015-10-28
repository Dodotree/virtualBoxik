#!/bin/bash

NEW_IP=
VM_NAME=

while [ "$1" ]; do
  	case $1 in
	-n | --name) 
		VM_NAME="$2";
       		shift;;

  	-i| --ip) 
		NEW_IP="$2";
       		shift;;

	* ) 	echo "$0: Unrecognized option \"$1\"" >&2
	 	exit 2;;
	esac
	shift
done

##Uses global ssh config, creates lock for it.
source $(dirname $0)/boxik_config
LOCKDIR="/var/lock/boxikHostFileLock"

digit="(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])"
IP_EXP="\b$digit\.$digit\.$digit\.$digit\b"

##Ed requires newlines for insert etc., using this to add them into double-quotes.
N=$'\n'

##Verifying VM name is not empty
if [ -z "$VM_NAME" ];then
	echo "$0: VM name is undefined." >&2
	exit 2
fi

##Validating new IP
if ! [[ $NEW_IP =~ $IP_EXP ]];then
    	echo "$0: Invalid new-IP. \"$NEW_IP\"" >&2
    	exit 2
fi

##Lock file, only one script can edit file at a time. So as to prevent file-exists spam, 2>null
until mkdir $LOCKDIR 2>/dev/null
do    
    sleep 0.5 ##Other scripts etc. might edit the hostfile (clean is an example)
done

##Prints $END if the there isn't a host with the name VM_NAME, since it reaches end of buffer.
output=$(2>/dev/null ed -s $HOSTFILE <<< "/$START/,/$END/ g/\b$VM_NAME\b/+s/HostName [0-9\.]*/HostName $NEW_IP/${N}w${N}p")

##Insert right before end of boxik host section if hostname doesn't exist yet
if [ "$output" == "$END" ];then 
	ed -s $HOSTFILE <<< "/$END/i${N}Host $VM_NAME${N}    HostName $NEW_IP$N    User $BOXIK_USER$N    IdentityFile $BOXIK_KEY${N}.${N}w"
fi

##Assumes start/end already in there just as before.
##If host not in ansible/hosts file then adds it.
if [ "$(2>/dev/null ed -s $ANS_HOSTS <<< "/$ANS_START/,/$ANS_END/ g/\b$VM_NAME\b/${N}p")" == "$ANS_END" ];then
	ed -s $ANS_HOSTS <<< "/$ANS_END/i$N$VM_NAME${N}.${N}w"
fi

echo "$0: Succeeded in adding IP $NEW_IP for $VM_NAME"

##Clear lock
rm -r $LOCKDIR
